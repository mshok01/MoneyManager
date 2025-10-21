import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'logging_service.dart';

/// Service to handle Firebase Authentication (anonymous sign-in)
class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  static FirebaseAuthService get instance => _instance;
  FirebaseAuthService._internal();

  // Logger instance for this service
  static final _log = LoggingService.getLogger('FirebaseAuthService');

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  UserCredential? _currentCredential;

  /// Get the current Firebase ID token
  Future<String?> getIdToken([bool forceRefresh = false]) async {
    _log.entering('getIdToken');
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        _log.w('No authenticated user found');
        _log.exiting('getIdToken', null);
        return null;
      }

      final idToken = await user.getIdToken(forceRefresh);
      _log.d('ID token retrieved successfully');
      _log.exiting('getIdToken', idToken != null);
      return idToken;
    } catch (e) {
      _log.e('Failed to get ID token', error: e);
      _log.exiting('getIdToken', null);
      return null;
    }
  }

  /// Get the current Firebase UID
  String? getUid() {
    return _firebaseAuth.currentUser?.uid;
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _firebaseAuth.currentUser != null;
  }

  /// Sign in anonymously
  Future<UserCredential?> signInAnonymously() async {
    _log.entering('signInAnonymously');
    try {
      _log.d('Starting anonymous sign-in');
      _currentCredential = await _firebaseAuth.signInAnonymously();
      _log.i(
        'Anonymous sign-in successful, UID: ${_currentCredential?.user?.uid}',
      );
      _log.exiting('signInAnonymously', true);
      return _currentCredential;
    } catch (e) {
      _log.e('Anonymous sign-in failed', error: e);
      _log.exiting('signInAnonymously', null);
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _log.entering('signOut');
    try {
      await _firebaseAuth.signOut();
      _currentCredential = null;
      _log.i('Sign out successful');
      _log.exiting('signOut');
    } catch (e) {
      _log.e('Sign out failed', error: e);
      _log.exiting('signOut');
      rethrow;
    }
  }

  /// Delete the current user
  Future<void> deleteCurrentUser() async {
    _log.entering('deleteCurrentUser');
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
        _currentCredential = null;
        _log.i('User deleted successfully');
      }
      _log.exiting('deleteCurrentUser');
    } catch (e) {
      _log.e('Failed to delete user', error: e);
      _log.exiting('deleteCurrentUser');
      rethrow;
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Refresh ID token
  Future<String?> refreshIdToken() async {
    _log.entering('refreshIdToken');
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        _log.w('No authenticated user found');
        _log.exiting('refreshIdToken', null);
        return null;
      }

      final idToken = await user.getIdToken(true);
      _log.d('ID token refreshed successfully');
      _log.exiting('refreshIdToken', idToken != null);
      return idToken;
    } catch (e) {
      _log.e('Failed to refresh ID token', error: e);
      _log.exiting('refreshIdToken', null);
      return null;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      await GoogleSignIn.instance.initialize(
        serverClientId:
            '1067746733059-uvv7ihminqujasv6v34o1i5sdee7c2v3.apps.googleusercontent.com',
      );

      final googleUser = await GoogleSignIn.instance.authenticate();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      _log.e(e.toString());
      return null;
    }
  }
}
