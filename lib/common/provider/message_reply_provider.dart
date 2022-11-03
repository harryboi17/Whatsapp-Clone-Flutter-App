import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';

class MessageReply{
  final String message;
  final bool isMe;
  final MessageEnum messageEnum;
  final String repliedTo;

  MessageReply({required this.message, required this.isMe, required this.messageEnum, required this.repliedTo});
}

final messageReplyProvider = StateProvider<MessageReply?>((ref) => null);