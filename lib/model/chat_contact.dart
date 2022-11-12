class ChatContact{
  final String name;
  final String profilePic;
  final String contactId;
  final DateTime timeSent;
  final String lastMessage;
  final bool isTyping;
  final bool isActiveOnScreen;
  final String userTyping;
  final int unSeenMessageCount;
  final String phoneNumber;
  final String? fcmToken;
  final bool isGroupChat;
  final List<String> membersUid;

  ChatContact({
    required this.name,
    required this.profilePic,
    required this.contactId,
    required this.timeSent,
    required this.lastMessage,
    required this.isTyping,
    required this.isActiveOnScreen,
    required this.unSeenMessageCount,
    required this.phoneNumber,
    required this.isGroupChat,
    required this.membersUid,
    required this.userTyping,
    required this.fcmToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profilePic': profilePic,
      'contactId': contactId,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
      'isTyping' : isTyping,
      'unSeenMessageCount': unSeenMessageCount,
      'phoneNumber' : phoneNumber,
      'isGroupChat' : isGroupChat,
      'membersUid' : membersUid,
      'userTyping' : userTyping,
      'fcmToken' : fcmToken,
      'isActiveOnScreen' : isActiveOnScreen,
    };
  }

  factory ChatContact.fromMap(Map<String, dynamic> map) {
    return ChatContact(
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      contactId: map['contactId'] ?? '',
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      lastMessage: map['lastMessage'] ?? '',
      isTyping: map['isTyping'] ?? false,
      isActiveOnScreen: map['isActiveOnScreen'] ?? false,
      unSeenMessageCount: map['unSeenMessageCount'] ?? 0,
      phoneNumber: map['phoneNumber'] ?? '',
      isGroupChat: map['isGroupChat'] ?? false,
      membersUid: List<String>.from(map['membersUid']),
      userTyping: map['userTyping'] as String,
      fcmToken: map['fcmToken'],
    );
  }
}