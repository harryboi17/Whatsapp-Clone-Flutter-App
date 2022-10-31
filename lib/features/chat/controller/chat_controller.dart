import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/provider/message_reply_provider.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/features/chat/repository/chat_repository.dart';
import 'package:whatsapp_clone/features/chat/screens/forward_screen.dart';
import 'package:whatsapp_clone/features/chat/widgets/app_bar.dart';
import 'package:whatsapp_clone/model/chat_contact.dart';
import '../../../common/enums/message_enum.dart';
import '../../../model/message.dart';
import '../../../model/user_model.dart';

final chatControllerProvider = Provider((ref){
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(chatRepository: chatRepository, ref: ref);
});

class ChatController {
  final ChatRepository chatRepository;
  final ProviderRef ref;

  ChatController({required this.chatRepository, required this.ref});

  Stream<List<ChatContact>> chatContacts(){
    return chatRepository.getChatContacts();
  }
  Future<List<ChatContact>> futureChatContacts(){
    return chatRepository.getFutureChatContacts();
  }
  Stream<List<ChatContact>> chatGroups(){
    return chatRepository.getChatGroups();
  }
  Future<List<ChatContact>> futureChatGroups(){
    return chatRepository.getFutureChatGroups();
  }

  Stream<List<Message>> chatStream(String receiverUserId){
    return chatRepository.getChatStream(receiverUserId);
  }
  Stream<List<Message>> groupChatStream(String groupId){
    return chatRepository.getGroupChatStream(groupId);
  }

  Future<List<ChatContact>> getSearchedContacts(){
    return chatRepository.getSearchedContacts();
  }

  void sendTextMessage(BuildContext context, String text, String receiverUserId, bool isGroupChat) {
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).whenData((value) =>
        chatRepository.sendTextMessage(
          context: context,
          text: text,
          receiverUserId: receiverUserId,
          senderUser: value!,
          messageReply : messageReply,
          isGroupChat: isGroupChat,
        )
    );
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  void sendFileMessage(BuildContext context, File file, String receiverUserId, MessageEnum messageEnum, bool isGroupChat) {
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).whenData((value) =>
        chatRepository.sendFileMessage(
          context: context,
          file : file,
          receiverUserId: receiverUserId,
          senderUserData: value!,
          messageEnum: messageEnum,
          ref: ref,
          messageReply: messageReply,
          isGroupChat : isGroupChat,
        )
    );
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  void sendGIFMessage(BuildContext context, String gifUrl, String receiverUserId, bool isGroupChat){
    // https://i.giphy.com/media/fn2kee68mheQgMtz1k
    int gifUrlPartIndex = gifUrl.lastIndexOf('-') + 1;
    String gifUrlPart = gifUrl.substring(gifUrlPartIndex);
    String newUrl = 'https://i.giphy.com/media/$gifUrlPart/200.gif';
    final messageReply = ref.read(messageReplyProvider);

    ref.read(userDataAuthProvider).whenData((value) =>
        chatRepository.sendGIFMessage(
            context: context,
            gifUrl: newUrl,
            receiverUserId: receiverUserId,
            senderUser: value!,
            messageReply: messageReply,
            isGroupChat: isGroupChat,
        )
    );
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  void setChatMessageSeen({
    required BuildContext context,
    required String receiverUserId,
    required String messageId,
  }){
    chatRepository.setChatMessageSeen(context: context, receiverUserId: receiverUserId, messageId: messageId);
  }
  void updateGroupMessageSeen({
    required BuildContext context,
    required String groupId,
    required String messageId,
    required List<String> seenBy,
  }){
    chatRepository.updateGroupChatMessageSeen(context, seenBy, groupId, messageId);
  }

  void setUnSeenMessageCount({
    required BuildContext context,
    required String senderUserId,
    required String receiverUserId,
    required int unSeenMessageCount,
    required bool isGroupChat,
  }){
    chatRepository.setUnSeenMessageCount(context: context, receiverUserId: receiverUserId, unSeenMessageCount: unSeenMessageCount, senderUserId: senderUserId, isGroupChat: isGroupChat);
  }

  void deleteMessageForEveryone(List<Message> messages, bool isGroupChat, bool isLastMessageSelected){
    chatRepository.deleteMessagesForEveryone(messages, ref, isGroupChat, isLastMessageSelected);
  }

  void deleteMessageForMe(List<Message> messages, isGroupChat){
    chatRepository.deleteMessagesForMe(messages, isGroupChat);
  }

  void updateLastMessage(Message messageData, bool isGroupChat){
    chatRepository.updateLastMessage(messageData, isGroupChat);
  }

  void forwardMessage(BuildContext context) async {
    List<Message> messages = ref.read(appBarMessageProvider);
    messages.sort((Message a, Message b){
      return a.timeSent.compareTo(b.timeSent);
    });
    List<ChatContact> chatList = ref.read(chatContactProvider);
    UserModel? user = await ref.read(authControllerProvider).getUserData();
    chatRepository.forwardMessage(chatList, messages, context, user!);
  }
}
