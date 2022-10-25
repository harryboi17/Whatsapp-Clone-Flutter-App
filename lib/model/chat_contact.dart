class ChatContact{
  final String name;
  final String profilePic;
  final String contactId;
  final DateTime timeSent;
  final String lastMessage;
  final bool isTyping;
  final int unSeenMessageCount;
  final String phoneNumber;
  final bool isGroupChat;
  final int numberOfMembers;

  ChatContact({
    required this.name,
    required this.profilePic,
    required this.contactId,
    required this.timeSent,
    required this.lastMessage,
    required this.isTyping,
    required this.unSeenMessageCount,
    required this.phoneNumber,
    required this.isGroupChat,
    required this.numberOfMembers,
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
      'numberOfMembers' : numberOfMembers,
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
      phoneNumber: map['phoneNumber'] ?? '',
      isGroupChat: map['isGroupChat'] ?? false,
      numberOfMembers: map['numberOfMembers'] ?? 1,
    );
  }
}