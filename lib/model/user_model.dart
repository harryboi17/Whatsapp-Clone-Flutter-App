class UserModel{
  final String name;
  final String uid;
  final String profilePic;
  final bool isOnline;
  final bool isTyping;
  final String phoneNumber;
  final String? token;
  final List<String> groupId;

  UserModel({required this.name, required this.uid, required this.profilePic, required this.isOnline, required this.phoneNumber, required this.groupId, required this.isTyping, required this.token});
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uid': uid,
      'profilePic': profilePic,
      'isOnline': isOnline,
      'isTyping' : isTyping,
      'phoneNumber': phoneNumber,
      'groupId': groupId,
      'token' : token,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      uid: map['uid'] ?? '',
      profilePic: map['profilePic'] ?? '',
      isOnline: map['isOnline'] ?? false,
      isTyping: map['isTyping'] ?? false,
      phoneNumber: map['phoneNumber'] ?? '',
      groupId: List<String>.from(map['groupId']),
      token: map['token'] ?? '',
    );
  }


}