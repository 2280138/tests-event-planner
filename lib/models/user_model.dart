class CustomUser {
  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;

  CustomUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'displayName': displayName,
    'email': email,
    'photoUrl': photoUrl,
  };

  factory CustomUser.fromMap(Map<String, dynamic> map) {
    return CustomUser(
      uid: map['uid'],
      displayName: map['displayName'],
      email: map['email'],
      photoUrl: map['photoUrl'],
    );
  }
}
