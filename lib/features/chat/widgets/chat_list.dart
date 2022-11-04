import 'dart:async';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';
import 'package:whatsapp_clone/common/provider/message_reply_provider.dart';
import 'package:whatsapp_clone/common/widgets/loader.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_clone/features/chat/widgets/senders_message_card.dart';
import '../../../model/message.dart';
import 'app_bar.dart';
import 'my_message_card.dart';

class ChatList extends ConsumerStatefulWidget {
  final String receiverUserId;
  final bool isGroupChat;
  final int numberOfMembers;

  const ChatList(
      {Key? key, required this.receiverUserId, required this.isGroupChat, required this.numberOfMembers,}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  late final AutoScrollController messageController;
  final String senderUserid = FirebaseAuth.instance.currentUser!.uid;
  int total = 0;
  List<Message> messages = [];

  @override
  void initState() {
    messageController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  void onMessageSwipe(
      {required String message, required String repliedTo, required bool isMe, required MessageEnum messageEnum, required String repliedMessageId,})async {
    var user =  await ref.read(authControllerProvider).userData(repliedTo);
    ref.read(messageReplyProvider.notifier).update((state) =>
        MessageReply(message: message, isMe: isMe, messageEnum: messageEnum, repliedTo: user.name, repliedMessageId: repliedMessageId));
  }

  void onMessageLongPressed(Message message, int index){
    if(ref.read(chatScreenAppBarProvider) == false){
      ref.read(chatScreenAppBarProvider.notifier).update((state) => true);
      onMessagePressed(message, index);
    }
  }

  void onMessagePressed(Message message, int index){
    if(ref.read(chatScreenAppBarProvider) == true){
      if(index == total-1){
        ref.read(isLastMessageSelectedProvider.notifier).update((state) => !state);
      }
      if(ref.read(appBarMessageProvider).contains(message)){
        ref.read(appBarMessageProvider.notifier).update((state){
          state.remove(message);
          return state;
        });
        ref.read(appBarMessageProvider.notifier).update((state) => [...state]);
        if(ref.read(appBarMessageProvider).isEmpty){
          ref.read(chatScreenAppBarProvider.notifier).update((state) => false);
        }
      }else{
        ref.read(appBarMessageProvider.notifier).update((state) => [...state, message]);
      }

    }
  }

  void onRepliedMessagePressed(String repliedMessageId)async{
    for(int i = 0; i < messages.length; i++){
      if(messages[i].messageId == repliedMessageId){
        await messageController.scrollToIndex(i, preferPosition: AutoScrollPosition.middle).whenComplete(() =>
            ref.read(animationProvider.notifier).update((state) => messages[i].messageId)
        );
        break;
      }
    }
  }
  
  @override
  Widget build(BuildContext context){
    return widget.isGroupChat
        ? StreamBuilder<List<Message>>(
            stream: ref.read(chatControllerProvider).groupChatStream(widget.receiverUserId),
            builder: (context, snapshot){
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }

              SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                if (messageController.hasClients) {
                  messageController.animateTo(messageController.position.maxScrollExtent, duration:const Duration(milliseconds: 200), curve: Curves.easeOut, );
                  // messageController.jumpTo(messageController.position.maxScrollExtent);
                }else{
                  Timer(const Duration(milliseconds: 400), () => messageController.jumpTo(messageController.position.maxScrollExtent));
                }
              });

              String myUid = ref.read(authControllerProvider).uid();
              ref.read(chatControllerProvider).setUnSeenMessageCount(context: context, senderUserId: "", receiverUserId: widget.receiverUserId, unSeenMessageCount: 0, isGroupChat: true);
              messages = [];
              for(var message in snapshot.data!){
                if(!message.deletedBy.contains(myUid)){
                  messages.add(message);
                }
              }
              total = messages.length;
              return ListView.builder(
                controller: messageController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final messageData = messages[index];

                  List<String> seenSet = messageData.seenBy;
                  if(!seenSet.contains(FirebaseAuth.instance.currentUser!.uid)) {
                    seenSet.add(FirebaseAuth.instance.currentUser!.uid);
                    ref.read(chatControllerProvider).updateGroupMessageSeen(context: context, groupId: widget.receiverUserId, messageId: messageData.messageId, seenBy: seenSet);
                  }

                  if(index == total-1){
                    ref.read(chatControllerProvider).updateLastMessage(messageData, widget.isGroupChat);
                  }

                  if (messageData.senderId == FirebaseAuth.instance.currentUser!.uid) {
                    return AutoScrollTag(
                      index: index,
                      key: ValueKey(index),
                      controller: messageController,
                      child: MyMessageCard(
                        onPressed: () => onMessagePressed(messageData, index),
                        onLongPressed: () => onMessageLongPressed(messageData, index),
                        onSwipe: () => onMessageSwipe(
                          message: messageData.text,
                          isMe: true,
                          messageEnum: messageData.type,
                          repliedTo: messageData.senderId,
                          repliedMessageId: messageData.messageId,
                        ),
                        onRepliedMessagePressed : () => onRepliedMessagePressed(messageData.repliedToId),
                        isSeen: messageData.seenBy.length == widget.numberOfMembers,
                        messageData: messageData,
                      ),
                    );
                  }
                  return AutoScrollTag(
                    index: index,
                    key: ValueKey(index),
                    controller: messageController,
                    child: SenderMessageCard(
                      onPressed: () => onMessagePressed(messageData, index),
                      onLongPressed: () => onMessageLongPressed(messageData, index),
                      onSwipe: () => onMessageSwipe(
                        message: messageData.text,
                        isMe: false,
                        messageEnum: messageData.type,
                        repliedTo: messageData.senderId,
                        repliedMessageId: messageData.messageId,
                      ),
                      onRepliedMessagePressed : () => onRepliedMessagePressed(messageData.repliedToId),
                      messageData: messageData,
                      isGroupChat: widget.isGroupChat,
                    ),
                  );
                },
              );
            })
        : StreamBuilder<List<Message>>(
            stream: ref.read(chatControllerProvider).chatStream(widget.receiverUserId),
            builder: (context, snapshot) {
              int unSeenMessageCount = 0;
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }

              SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                if (messageController.hasClients) {
                  // messageController.jumpTo(messageController.position.maxScrollExtent);
                  messageController.animateTo(messageController.position.maxScrollExtent, duration:const Duration(milliseconds: 200), curve: Curves.easeOut, );
                }
              });
              messages = snapshot.data!;
              total = snapshot.data!.length;
              ref.read(chatControllerProvider).setUnSeenMessageCount(context: context, receiverUserId: senderUserid, unSeenMessageCount: 0, senderUserId: widget.receiverUserId, isGroupChat: widget.isGroupChat,);

              return ListView.builder(
                controller: messageController,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final messageData = snapshot.data![index];

                  if (messageData.seenBy.length != 2) {
                    if (messageData.receiverId == FirebaseAuth.instance.currentUser!.uid) {
                      ref.read(chatControllerProvider).setChatMessageSeen(context: context, receiverUserId: widget.receiverUserId, messageId: messageData.messageId);
                    } else {
                      unSeenMessageCount += 1;
                      if (index == snapshot.data!.length - 1) {
                        ref.read(chatControllerProvider).setUnSeenMessageCount(context: context, receiverUserId: widget.receiverUserId, unSeenMessageCount: unSeenMessageCount, senderUserId: senderUserid, isGroupChat: widget.isGroupChat,);
                      }
                    }
                  }

                  if(index == snapshot.data!.length - 1) {
                    ref.read(chatControllerProvider).updateLastMessage(messageData, widget.isGroupChat);
                  }

                  if (messageData.senderId == FirebaseAuth.instance.currentUser!.uid) {
                    return AutoScrollTag(
                      index: index,
                      key: ValueKey(index),
                      controller: messageController,
                      child: MyMessageCard(
                        onPressed: () => onMessagePressed(messageData, index),
                        onLongPressed: () => onMessageLongPressed(messageData, index),
                        onSwipe: () => onMessageSwipe(
                          message: messageData.text,
                          isMe: true,
                          messageEnum: messageData.type,
                          repliedTo: messageData.senderId,
                          repliedMessageId: messageData.messageId,
                        ),
                        onRepliedMessagePressed: () => onRepliedMessagePressed(messageData.repliedToId),
                        isSeen: messageData.seenBy.length == 2,
                        messageData: messageData,
                      ),
                    );
                  }
                  return AutoScrollTag(
                    index: index,
                    key: ValueKey(index),
                    controller: messageController,
                    child: SenderMessageCard(
                      onPressed: () => onMessagePressed(messageData, index),
                      onLongPressed: () => onMessageLongPressed(messageData, index),
                      onSwipe: () => onMessageSwipe(
                        message: messageData.text,
                        isMe: false,
                        messageEnum: messageData.type,
                        repliedTo: messageData.senderId,
                        repliedMessageId: messageData.messageId,
                      ),
                      onRepliedMessagePressed : () => onRepliedMessagePressed(messageData.repliedToId),
                      messageData: messageData,
                      isGroupChat: widget.isGroupChat,
                    ),
                  );
                },
              );
            });
  }
}
