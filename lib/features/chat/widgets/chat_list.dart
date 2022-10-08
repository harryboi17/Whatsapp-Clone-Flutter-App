import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';
import 'package:whatsapp_clone/common/provider/message_reply_provider.dart';
import 'package:whatsapp_clone/common/widgets/loader.dart';
import 'package:whatsapp_clone/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_clone/features/chat/widgets/senders_message_card.dart';
import '../../../model/message.dart';
import 'my_message_card.dart';

class ChatList extends ConsumerStatefulWidget {
  final String receiverUserId;
  final bool isGroupChat;
  final int numberOfMembers;

  const ChatList(
      {Key? key, required this.receiverUserId, required this.isGroupChat, required this.numberOfMembers})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messageController = ScrollController();
  final String senderUserid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (messageController.hasClients) {
        messageController.jumpTo(messageController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  void onMessageSwipe(
      {required String message,
      required bool isMe,
      required MessageEnum messageEnum}) {
    ref.read(messageReplyProvider.state).update((state) =>
        MessageReply(message: message, isMe: isMe, messageEnum: messageEnum));
  }

  @override
  Widget build(BuildContext context) {
    return widget.isGroupChat
        ? StreamBuilder<List<GroupMessage>>(
            stream: ref.read(chatControllerProvider).groupChatStream(widget.receiverUserId),
            builder: (context, snapshot){
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }

              SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                if (messageController.hasClients) {
                  messageController
                      .jumpTo(messageController.position.maxScrollExtent);
                }
              });

              ref.read(chatControllerProvider).setUnSeenMessageCount(context: context, senderUserId: "", receiverUserId: widget.receiverUserId, unSeenMessageCount: 0, isGroupChat: true);

              return ListView.builder(
                controller: messageController,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final messageData = snapshot.data![index];
                  var timeSent = DateFormat.jm().format(messageData.timeSent);
                  String repliedMessage = messageData.text.length > 70
                      ? "${messageData.text.substring(0, 70)}..."
                      : messageData.text;

                  List<String> seenSet = messageData.seenBy;
                  if(!seenSet.contains(FirebaseAuth.instance.currentUser!.uid)) {
                    seenSet.add(FirebaseAuth.instance.currentUser!.uid);
                    ref.read(chatControllerProvider).updateGroupMessageSeen(context: context, groupId: widget.receiverUserId, messageId: messageData.messageId, seenBy: seenSet);
                  }

                  if (messageData.senderId ==
                      FirebaseAuth.instance.currentUser!.uid) {
                    return MyMessageCard(
                      message: messageData.text,
                      date: timeSent,
                      type: messageData.type,
                      repliedText: messageData.repliedMessage,
                      userName: messageData.repliedTo,
                      repliedMessageType: messageData.repliedMessageType,
                      onSwipe: () => onMessageSwipe(
                          message: messageData.type == MessageEnum.text
                              ? repliedMessage
                              : messageData.text,
                          isMe: true,
                          messageEnum: messageData.type),
                      // isSeen: messageData.seenBy.length == widget.numberOfMembers,
                      isSeen: messageData.seenBy.length == widget.numberOfMembers,
                    );
                  }
                  return SenderMessageCard(
                    message: messageData.text,
                    date: timeSent,
                    type: messageData.type,
                    repliedText: messageData.repliedMessage,
                    userName: messageData.repliedTo,
                    repliedMessageType: messageData.repliedMessageType,
                    onSwipe: () => onMessageSwipe(
                      message: messageData.type == MessageEnum.text
                          ? repliedMessage
                          : messageData.text,
                      isMe: false,
                      messageEnum: messageData.type,
                    ),
                  );
                },
              );
            })
        : StreamBuilder<List<Message>>(
            stream: ref
                .read(chatControllerProvider)
                .chatStream(widget.receiverUserId),
            builder: (context, snapshot) {
              int unSeenMessageCount = 0;
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }

              SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                if (messageController.hasClients) {
                  messageController
                      .jumpTo(messageController.position.maxScrollExtent);
                }
              });

              ref.read(chatControllerProvider).setUnSeenMessageCount(context: context, receiverUserId: senderUserid, unSeenMessageCount: 0, senderUserId: widget.receiverUserId, isGroupChat: widget.isGroupChat,);

              return ListView.builder(
                controller: messageController,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final messageData = snapshot.data![index];
                  var timeSent = DateFormat.jm().format(messageData.timeSent);
                  String repliedMessage = messageData.text.length > 70
                      ? "${messageData.text.substring(0, 70)}..."
                      : messageData.text;

                  if (!messageData.isSeen) {
                    if (messageData.receiverId == FirebaseAuth.instance.currentUser!.uid) {
                      ref.read(chatControllerProvider).setChatMessageSeen(context: context, receiverUserId: widget.receiverUserId, messageId: messageData.messageId);
                    } else {
                      unSeenMessageCount += 1;
                      if (index == snapshot.data!.length - 1) {
                        ref.read(chatControllerProvider).setUnSeenMessageCount(context: context,receiverUserId: widget.receiverUserId,unSeenMessageCount: unSeenMessageCount,senderUserId: senderUserid,isGroupChat: widget.isGroupChat,);
                      }
                    }
                  }

                  if (messageData.senderId ==
                      FirebaseAuth.instance.currentUser!.uid) {
                    return MyMessageCard(
                      message: messageData.text,
                      date: timeSent,
                      type: messageData.type,
                      repliedText: messageData.repliedMessage,
                      userName: messageData.repliedTo,
                      repliedMessageType: messageData.repliedMessageType,
                      onSwipe: () => onMessageSwipe(
                          message: messageData.type == MessageEnum.text
                              ? repliedMessage
                              : messageData.text,
                          isMe: true,
                          messageEnum: messageData.type),
                      isSeen: messageData.isSeen,
                    );
                  }
                  return SenderMessageCard(
                    message: messageData.text,
                    date: timeSent,
                    type: messageData.type,
                    repliedText: messageData.repliedMessage,
                    userName: messageData.repliedTo,
                    repliedMessageType: messageData.repliedMessageType,
                    onSwipe: () => onMessageSwipe(
                      message: messageData.type == MessageEnum.text
                          ? repliedMessage
                          : messageData.text,
                      isMe: false,
                      messageEnum: messageData.type,
                    ),
                  );
                },
              );
            });
  }
}
