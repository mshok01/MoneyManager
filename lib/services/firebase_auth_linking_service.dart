import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:money_manager/models/firebase_user_details.dart';
import 'package:money_manager/services/firebase_auth_service.dart';
import 'logging_service.dart';
import 'auth_api_service.dart';
import 'user_service.dart';
import 'preferences_service.dart';

/// Exception thrown when a Google account already has data
class GoogleAccountAlreadyExistsException implements Exception {
  final String message;
  final String? googleEmail;
  final String? googleUserId;
  final String?
  errorCode; // Firebase error code: credential-already-in-use or email-already-in-use

  GoogleAccountAlreadyExistsException({
    required this.message,
    this.googleEmail,
    this.googleUserId,
    this.errorCode,
  });

  @override
  String toString() => message;
}

/// Service to handle Firebase authentication linking
/// Manages linking anonymous accounts with Google accounts
class FirebaseAuthLinkingService {
  static final FirebaseAuthLinkingService _instance =
      FirebaseAuthLinkingService._internal();
  static FirebaseAuthLinkingService get instance => _instance;
  FirebaseAuthLinkingService._internal();

  static final _log = LoggingService.getLogger('FirebaseAuthLinkingService');

  final _firebaseAuth = FirebaseAuth.instance;

  /// Get Google OAuth credential
  Future<OAuthCredential?> _getGoogleOAuthCredential() async {
    _log.entering('_getGoogleOAuthCredential');
    try {
      _log.d('Starting Google Sign-In flow');

      // Trigger the authentication flow
      await GoogleSignIn.instance.initialize(
        serverClientId:
            '1067746733059-uvv7ihminqujasv6v34o1i5sdee7c2v3.apps.googleusercontent.com',
      );
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      _log.d('Google user signed in: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      _log.d('Got authentication details');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      _log.d('Google OAuth credential obtained');
      _log.exiting('_getGoogleOAuthCredential', true);
      return credential;
    } catch (e) {
      _log.e('Failed to get Google OAuth credential', error: e);
      rethrow;
    }
  }

  /// Link new Google account (Scenario 1: First time linking)
  /// Returns true if linking was successful
  /// Throws GoogleAccountAlreadyExistsException if the Google account already has data
  Future<bool> linkNewGoogleAccount() async {
    _log.entering('linkNewGoogleAccount');
    try {
      // Step 1: Get current anonymous user
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('No anonymous user logged in');
      }

      String? jwt = await FirebaseAuthService.instance.getIdToken(true);
      _log.d('JWT: $jwt');

      final anonymousIdToken = await currentUser.getIdToken();
      if (anonymousIdToken == null) {
        throw Exception('Failed to get anonymous ID token');
      }

      _log.d('Current anonymous user: ${currentUser.uid}');

      // Step 2: Get Google OAuth credential
      final googleCredential = await _getGoogleOAuthCredential();
      if (googleCredential == null) {
        throw Exception('Failed to get Google credential');
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _log.d('No user logged in');
        throw Exception('No user logged in');
      }

      final authApiService = AuthApiService.instance;

      FirebaseUserDetails newUserDetails = await _linkAuthCredential(
        googleCredential,
      );

      if (newUserDetails.linkingSuccess) {
        final response = await authApiService.linkNewGoogleAccount(
          anonymousIdToken: anonymousIdToken,
          googleEmail: newUserDetails.email,
          name: newUserDetails.name,
          profilePic: newUserDetails.profilePicture,
        );
        _log.d('Backend linking successful: $response');
        final userService = UserService.instance;
        await userService.updateCurrentUser(response.user);
        await FirebaseAuthService.instance.getIdToken(true);

        _log.d('Local user data updated');
      } else {
        // Account already exists - throw specific exception
        _log.d('Google account already has data: ${newUserDetails.email}');
        throw GoogleAccountAlreadyExistsException(
          message: 'This Google account already has data in Money Manager',
          googleEmail: newUserDetails.email,
          googleUserId: newUserDetails.firebaseUserUids.isNotEmpty
              ? newUserDetails.firebaseUserUids.first
              : null,
          errorCode: newUserDetails.errorCode,
        );
      }

      _log.d('Local user data updated');
      return true;
    } catch (e) {
      _log.e('Failed to link new Google account', error: e);
      _log.exiting('linkNewGoogleAccount', null);
      rethrow;
    }
  }

  Future<FirebaseUserDetails> _linkAuthCredential(
    AuthCredential credential,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _log.d("user credentials not found");
      throw 'Unauthenticated user';
    }

    try {
      UserCredential userCredentials = await user.linkWithCredential(
        credential,
      );
      _log.d(userCredentials.additionalUserInfo!.isNewUser);
      FirebaseUserDetails personDetails = await _getUserDetailsFromAuth(
        userCredentials.user!,
      );
      personDetails.linkingSuccess = true;

      return personDetails;
    } on FirebaseAuthException catch (ex) {
      /// Names:
      ///  anonymous account: A account
      ///  previous google account: B account
      /// get DATA: personId, profile,...,  of A account
      /// get most up-to-date idToken from A account (force-refresh = true): idToken_A
      /// logout from A account
      /// login with B account
      /// get idToken from B account: idToken_B
      /// call a method on the server to link DATA to b account, passing idToken_A and idToken_B

      _log.w(ex);
      FirebaseUserDetails details = FirebaseUserDetails(
        name: '',
        phone: '',
        email: '',
        profilePicture: '',
        secondaryEmails: [],
        secondaryPhoneNumbers: [],
        firebaseUserUids: [],
        createdAt: 0,
        updatedAt: 0,
        errorCode: ex.code,
        linkingSuccess: false,
      );

      return details;
    } catch (e) {
      _log.e(e);
      rethrow;
    }
  }

  Future<FirebaseUserDetails> _getUserDetailsFromAuth(User user) async {
    String uId = user.uid;
    String name = user.displayName ?? "";
    List<String?> emails = user.email != null ? [user.email] : [];
    List<String?> phoneNumbers = user.phoneNumber != null
        ? [user.phoneNumber]
        : [];
    String profilePic = user.photoURL ?? "";
    String primaryMail = user.email ?? "";
    String primaryMobileNumber = user.phoneNumber ?? "";
    int createdAt = DateTime.now().toUtc().millisecondsSinceEpoch;
    int updatedAt = createdAt;
    return FirebaseUserDetails(
      name: name,
      phone: primaryMobileNumber,
      email: primaryMail,
      profilePicture: profilePic,
      secondaryEmails: emails,
      secondaryPhoneNumbers: phoneNumbers,
      firebaseUserUids: [uId],
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Link existing Google account (Scenario 2: Account already has data)
  /// Returns true if linking and data migration was successful
  Future<bool> linkExistingGoogleAccount() async {
    _log.entering('linkExistingGoogleAccount');
    try {
      // Step 1: Get current anonymous user
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('No anonymous user logged in');
      }

      final anonymousIdToken = await currentUser.getIdToken();
      if (anonymousIdToken == null) {
        throw Exception('Failed to get anonymous ID token');
      }

      final anonymousUserId = currentUser.uid;
      _log.d('Current anonymous user: $anonymousUserId');

      // Step 2: Get Google OAuth credential
      final googleCredential = await _getGoogleOAuthCredential();
      if (googleCredential == null) {
        throw Exception('Failed to get Google credential');
      }

      // Step 3: Sign in with Google to get Google user details
      final googleUserCredential = await _firebaseAuth.signInWithCredential(
        googleCredential,
      );
      final googleUser = googleUserCredential.user;
      if (googleUser == null) {
        throw Exception('Failed to sign in with Google');
      }

      final googleIdToken = await googleUser.getIdToken();
      if (googleIdToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      final googleUserId = googleUser.uid;
      _log.d('Google user signed in: $googleUserId');

      // Step 4: Call backend to link and migrate data
      final authApiService = AuthApiService.instance;
      final response = await authApiService.linkExistingGoogleAccount(
        anonymousIdToken: anonymousIdToken,
        googleIdToken: googleIdToken,
        anonymousUserId: anonymousUserId,
        googleUserId: googleUserId,
      );

      _log.d('Backend linking and migration successful');
      _log.d('Merged data: ${response.mergedData}');

      // Step 5: Update local user data
      final userService = UserService.instance;
      await userService.updateCurrentUser(response.user);

      // Step 6: Save auth tokens
      final prefsService = await PreferencesService.getInstance();
      await prefsService.setAuthToken(response.authToken);

      _log.d('Local user data updated');
      _log.exiting('linkExistingGoogleAccount', true);
      return true;
    } catch (e) {
      _log.e('Failed to link existing Google account', error: e);
      _log.exiting('linkExistingGoogleAccount', null);
      rethrow;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    _log.entering('signOutGoogle');
    try {
      try {
        await FirebaseAuth.instance.signOut();
        _log.d('Signed out from Firebase');
      } catch (e) {
        _log.e('Failed to sign out from Firebase', error: e);
      }

      try {
        await GoogleSignIn.instance.signOut();
        _log.d('Signed out from Google');
      } catch (e) {
        _log.e('Failed to sign out from google_sign_in', error: e);
      }
    } catch (e) {
      _log.e('Failed to sign out', error: e);
    }
  }
}
