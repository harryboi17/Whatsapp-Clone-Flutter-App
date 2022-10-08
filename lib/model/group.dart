class Group {
  final String senderId;
  final String name;
  final String groupId;
  final String lastMessage;
  final String groupPic;
  final List<String> membersUid;
  final DateTime timeSent;
  final bool isTyping;
  final String userTyping;
  final int unSeenMessageCount;
  Group({
    required this.senderId,
    required this.name,
    required this.groupId,
    required this.lastMessage,
    required this.groupPic,
    required this.membersUid,
    required this.timeSent,
    required this.isTyping,
    required this.unSeenMessageCount,
    required this.userTyping
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'name': name,
      'groupId': groupId,
      'lastMessage': lastMessage,
      'groupPic': groupPic,
      'membersUid': membersUid,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'isTyping' : isTyping,
      'unSeenMessageCount': unSeenMessageCount,
      'userTyping' : userTyping,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      senderId: map['senderId'] ?? '',
      name: map['name'] ?? '',
      groupId: map['groupId'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      groupPic: map['groupPic'] ?? '',
      membersUid: List<String>.from(map['membersUid']),
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      isTyping: map['isTyping'] ?? false,
      unSeenMessageCount: map['unSeenMessageCount'] ?? 0,
      userTyping: map['userTyping'] ?? '',
    );
  }
}

class GroupDataModel{
  final String groupId;
  final String lastMessage;
  final int unSeenMessageCount;
  final bool isTyping;
  final String userTyping;
  final DateTime timeSent;
  final String groupName;
  final String groupPic;
  final List<String> membersUid;


  const GroupDataModel({
    required this.groupId,
    required this.lastMessage,
    required this.unSeenMessageCount,
    required this.isTyping,
    required this.userTyping,
    required this.timeSent,
    required this.membersUid,
    required this.groupPic,
    required this.groupName,
  });

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'lastMessage': lastMessage,
      'unSeenMessageCount': unSeenMessageCount,
      'isTyping': isTyping,
      'userTyping': userTyping,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'groupName' : groupName,
      'groupPic' : groupPic,
      'membersUid': membersUid,
    };
  }

  factory GroupDataModel.fromMap(Map<String, dynamic> map) {
    return GroupDataModel(
      groupId: map['groupId'] as String,
      lastMessage: map['lastMessage'] as String,
      unSeenMessageCount: map['unSeenMessageCount'] as int,
      isTyping: map['isTyping'] as bool,
      userTyping: map['userTyping'] as String,
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      groupName: map['groupName'] as String,
      groupPic: map['groupPic'] as String,
      membersUid: List<String>.from(map['membersUid']),
    );
  }
}