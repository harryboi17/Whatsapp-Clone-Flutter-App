class ChatContact{
  final String name;
  final String profilePic;
  final String contactId;
  final DateTime timeSent;
  final String lastMessage;
  final bool isTyping;
  final int unSeenMessageCount;

  ChatContact({
    required this.name,
    required this.profilePic,
    required this.contactId,
    required this.timeSent,
    required this.lastMessage,
    required this.isTyping,
    required this.unSeenMessageCount
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
      unSeenMessageCount: map['unSeenMessageCount'] ?? 0,
    );
  }
}