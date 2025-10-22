class FirebaseUserDetails {
  String name;
  String phone;
  String email;
  String profilePicture;
  List<String?> secondaryEmails;
  List<String?> secondaryPhoneNumbers;
  List<String> firebaseUserUids;
  int createdAt;
  int updatedAt;
  bool linkingSuccess;
  String?
  errorCode; // Firebase error code when linking fails (e.g., credential-already-in-use, email-already-in-use)

  FirebaseUserDetails({
    required this.name,
    required this.phone,
    required this.email,
    required this.profilePicture,
    required this.secondaryEmails,
    required this.secondaryPhoneNumbers,
    required this.firebaseUserUids,
    required this.createdAt,
    required this.updatedAt,
    this.linkingSuccess = false,
    this.errorCode,
  });
}
