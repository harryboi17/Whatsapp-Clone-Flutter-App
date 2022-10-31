import '../common/enums/message_enum.dart';

class Message{
  final String senderId;
  final String receiverId;
  final String text;
  final MessageEnum type;
  final DateTime timeSent;
  final String messageId;
  final List<String> seenBy;
  final List<String> deletedBy;
  final String repliedMessage;
  final String repliedTo;
  final MessageEnum repliedMessageType;
  final bool isDeleted;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.type,
    required this.timeSent,
    required this.messageId,
    required this.seenBy,
    required this.repliedMessage,
    required this.repliedTo,
    required this.repliedMessageType,
    required this.isDeleted,
    required this.deletedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'type': type.type,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'messageId': messageId,
      'seenBy': seenBy,
      'deletedBy': deletedBy,
      'repliedMessage': repliedMessage,
      'repliedTo': repliedTo,
      'repliedMessageType': repliedMessageType.type,
      'isDeleted' : isDeleted,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      type: (map['type'] as String).toEnum(),
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      messageId: map['messageId'] ?? '',
      seenBy: List<String>.from(map['seenBy']),
      deletedBy: List<String>.from(map['deletedBy']),
      repliedMessage: map['repliedMessage'] ?? '',
      repliedTo: map['repliedTo'] ?? '',
      repliedMessageType: (map['repliedMessageType'] as String).toEnum(),
      isDeleted: map['isDeleted'] ?? false,
    );
  }

}