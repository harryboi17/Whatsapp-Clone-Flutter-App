import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';
import 'package:whatsapp_clone/common/provider/message_reply_provider.dart';
import 'package:whatsapp_clone/common/repository/firebase_storage_repository.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/features/notification/repository/notification_repository.dart';
import 'package:whatsapp_clone/model/chat_contact.dart';
import 'package:whatsapp_clone/model/message.dart';
import 'package:whatsapp_clone/model/user_model.dart';
import 'package:uuid/uuid.dart';

final chatRepositoryProvider = Provider(
    (ref) => ChatRepository(FirebaseFirestore.instance, FirebaseAuth.instance));

class ChatRepository {
  final FirebaseFirestore fireStore;
  final FirebaseAuth firebaseAuth;

  ChatRepository(this.fireStore, this.firebaseAuth);

  Stream<List<ChatContact>> getChatContacts() {
    return fireStore.collection('users').doc(firebaseAuth.currentUser!.uid).collection('chats').orderBy('timeSent', descending: true).snapshots()
        .map((event){
      List<ChatContact> contacts = [];
      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());
        contacts.add(chatContact);
      }
      return contacts;
    });
  }
  Future<List<ChatContact>> getFutureChatContacts() async{
    var chatContactSnapshot = await fireStore.collection('users').doc(firebaseAuth.currentUser!.uid).collection('chats').orderBy('timeSent', descending: true).get();
    List<ChatContact> contacts = [];
    for (var document in chatContactSnapshot.docs) {
      var chatContact = ChatContact.fromMap(document.data());
      contacts.add(chatContact);
    }
    return contacts;
  }

  Stream<List<ChatContact>> getChatGroups() {
    return fireStore.collection('users').doc(firebaseAuth.currentUser!.uid).collection('groups').orderBy('timeSent', descending: true)
        .snapshots().map((event){
          List<ChatContact> groups = [];
          for(var groupIdData in event.docs){
            ChatContact groupDataModel = ChatContact.fromMap(groupIdData.data());
            groups.add(groupDataModel);
          }
          return groups;
    });
  }
  Future<List<ChatContact>> getFutureChatGroups() async{
    var chatGroupsSnapshot = await fireStore.collection('users').doc(firebaseAuth.currentUser!.uid).collection('groups').orderBy('timeSent', descending: true).get();
    List<ChatContact> groups = [];
    for(var groupIdData in chatGroupsSnapshot.docs){
      ChatContact groupDataModel = ChatContact.fromMap(groupIdData.data());
      groups.add(groupDataModel);
    }
    return groups;
  }

  Stream<List<Message>> getChatStream(String receiverUserId) {
    return fireStore.collection('users').doc(firebaseAuth.currentUser!.uid).collection('chats').doc(receiverUserId).collection('messages')
        .orderBy('timeSent').snapshots().map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      return messages;
    });
  }
  Stream<List<Message>> getGroupChatStream(String groupId) {
    return fireStore.collection('groups').doc(groupId).collection('chats').orderBy('timeSent').snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      return messages;
    });
  }

  Future<List<ChatContact>> getSearchedContacts() async {
    var contactDataSnapshot = await fireStore.collection('users').doc(firebaseAuth.currentUser!.uid).collection('chats').orderBy('timeSent', descending: true).get();
    List<ChatContact> contacts = [];
    for (var document in contactDataSnapshot.docs) {
      var chatContact = ChatContact.fromMap(document.data());
      contacts.add(chatContact);
    }

    var groupDataSnapshot = await fireStore.collection('users').doc(firebaseAuth.currentUser!.uid).collection('groups').orderBy('timeSent', descending: true).get();
    for (var document in groupDataSnapshot.docs) {
      ChatContact groupDataModel = ChatContact.fromMap(document.data());
      contacts.add(groupDataModel);
    }
    contacts.sort((a,b) => b.timeSent.compareTo(a.timeSent));
    return contacts;
  }

  void _saveDataToContactsSubCollection({
    required UserModel senderUserData,
    required String receiverUserName,
    required String text,
    required DateTime timeSent,
    required String receiverUserId,
    required bool isGroupChat,
    required String? fcmToken,
  }) async {
    if(isGroupChat){
      fireStore.collection('groups').doc(receiverUserId).update({
        'lastMessage' : text,
        'timeSent' : DateTime.now().millisecondsSinceEpoch,
      });

      var groupData = await fireStore.collection('groups').doc(receiverUserId).get();
      List<String> membersId = List<String>.from(groupData.data()!['membersUid']);
      List<String?> membersFcmToken = List<String?>.from(groupData.data()!['membersFcmToken']);
      for(int i = 0; i < membersId.length; i++){
        fireStore.collection('users').doc(membersId[i]).collection('groups').doc(receiverUserId).update({
          'lastMessage' : text,
          'timeSent' : DateTime.now().millisecondsSinceEpoch,
        });

        var contactSnapshot = await fireStore.collection('users').doc(membersId[i]).collection('groups').doc(receiverUserId).get();
        ChatContact chatContact = ChatContact.fromMap(contactSnapshot.data()!);
        if(membersId[i] != firebaseAuth.currentUser!.uid && !chatContact.isActiveOnScreen){
          NotificationRepository.sendNotification(title: receiverUserName, message: '${senderUserData.name}: $text', token: membersFcmToken[i], collapseKey: receiverUserId);
        }
      }
    }
    else {
      //users -> receiver user id => chats -> current user id -> set data
      fireStore.collection('users').doc(receiverUserId).collection('chats').doc(firebaseAuth.currentUser!.uid).update({
        'lastMessage' : text,
        'timeSent' : timeSent.millisecondsSinceEpoch,
      });

      //users -> current user id => chats -> receiver user id -> set data
      fireStore.collection('users').doc(firebaseAuth.currentUser!.uid).collection('chats').doc(receiverUserId).update({
        'lastMessage' : text,
        'timeSent' : timeSent.millisecondsSinceEpoch,
      });
      var contactSnapshot = await fireStore.collection('users').doc(receiverUserId).collection('chats').doc(firebaseAuth.currentUser!.uid).get();
      ChatContact chatContact = ChatContact.fromMap(contactSnapshot.data()!);
      // if(!chatContact.isActiveOnScreen) {
        NotificationRepository.sendNotification(title: senderUserData.name, message: text, token: fcmToken, collapseKey: receiverUserId);
      // }
    }
  }

  void _saveMessageToMessageSubCollection({
    required String receiverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String userName,
    required MessageEnum messageType,
    required MessageReply? messageReply,
    required String? receiverUserName,
    required bool isGroupChat,
    required String senderName,
    required bool isForwarded,
  }) async {
    final message = Message(
      senderId: firebaseAuth.currentUser!.uid,
      receiverId: receiverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      seenBy: [],
      deletedBy: [],
      repliedMessage: messageReply == null ? '' : messageReply.message,
      repliedTo: messageReply == null ? '' : messageReply.isMe ? userName : receiverUserName ?? '',
      repliedMessageType: messageReply == null ? MessageEnum.text : messageReply.messageEnum,
      isDeleted: false,
      senderName: senderName,
      repliedToId: messageReply == null ? '' : messageReply.repliedMessageId,
      isForwarded: isForwarded,
    );
    if(isGroupChat){
      fireStore.collection('groups').doc(receiverUserId).collection('chats').doc(messageId).set(message.toMap());

      var groupData = await fireStore.collection('groups').doc(receiverUserId).get();
      List<String> membersId = List<String>.from(groupData.data()!['membersUid']);
      for(var uid in membersId){
        if(uid != firebaseAuth.currentUser!.uid) {
          fireStore.collection('users').doc(uid).collection('groups').doc(receiverUserId).update({
            'unSeenMessageCount' : FieldValue.increment(1),
          });
        }
      }
    }
    else {
      //users -> sender id -> receiver id -> messages -> message id -> store message
      fireStore.collection('users').doc(firebaseAuth.currentUser!.uid).collection('chats').doc(receiverUserId).collection('messages').doc(messageId)
          .set(message.toMap());
      //users -> receiver id -> sender id -> messages -> message id -> store message
      fireStore.collection('users').doc(receiverUserId).collection('chats').doc(firebaseAuth.currentUser!.uid).collection('messages').doc(messageId)
          .set(message.toMap());
    }
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String receiverUserId,
    required String receiverUserName,
    required UserModel senderUser,
    required MessageReply? messageReply,
    required bool isGroupChat,
    required bool isForwarded,
    required String? fcmToken,
  }) async {
    try {
      var timeSent = DateTime.now();

      var messageId = const Uuid().v1();

      _saveDataToContactsSubCollection(
        senderUserData: senderUser,
        receiverUserName: receiverUserName,
        // text: text.length > 30 ? "${text.substring(0,30)}..." : text,
        text: text,
        timeSent: timeSent,
        receiverUserId: receiverUserId,
        isGroupChat: isGroupChat,
        fcmToken: fcmToken,
      );
      _saveMessageToMessageSubCollection(
        receiverUserId: receiverUserId,
        text: text,
        timeSent: timeSent,
        messageId: messageId,
        userName: senderUser.name,
        receiverUserName: receiverUserName,
        messageType: MessageEnum.text,
        messageReply: messageReply,
        isGroupChat: isGroupChat,
        senderName: senderUser.name,
        isForwarded: isForwarded,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String receiverUserId,
    required String receiverUserName,
    required UserModel senderUserData,
    required ProviderRef ref,
    required MessageEnum messageEnum,
    required MessageReply? messageReply,
    required bool isGroupChat,
    required bool isForwarded,
    required String? fcmToken,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String imageUrl = await ref
          .read(commonFireBaseStorageRepositoryProvider)
          .storeFileToFirebase(
              'chat/${messageEnum.type}/${senderUserData.uid}/$receiverUserId/$messageId',
              file);

      String contactMsg = displayMessageForMessageType(messageEnum);

      _saveDataToContactsSubCollection(senderUserData: senderUserData, receiverUserName: receiverUserName, text: contactMsg,
          timeSent: timeSent, receiverUserId: receiverUserId, isGroupChat: isGroupChat, fcmToken: fcmToken);
      _saveMessageToMessageSubCollection(receiverUserId: receiverUserId, text: imageUrl, timeSent: timeSent, messageId: messageId, userName: senderUserData.name,
          receiverUserName: receiverUserName, messageType: messageEnum, messageReply: messageReply, isGroupChat: isGroupChat, senderName: senderUserData.name, isForwarded: isForwarded);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendGIFMessage({
    required BuildContext context,
    required String gifUrl,
    required String receiverUserId,
    required String receiverUserName,
    required UserModel senderUser,
    required MessageReply? messageReply,
    required bool isGroupChat,
    required bool isForwarded,
    required String? fcmToken,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      _saveDataToContactsSubCollection(
        senderUserData: senderUser,
        receiverUserName: receiverUserName,
        text: '👾 GIF',
        timeSent: timeSent,
        receiverUserId: receiverUserId,
        isGroupChat: isGroupChat,
        fcmToken: fcmToken,
      );
      _saveMessageToMessageSubCollection(
        receiverUserId: receiverUserId,
        text: gifUrl,
        timeSent: timeSent,
        messageId: messageId,
        userName: senderUser.name,
        receiverUserName: receiverUserName,
        messageType: MessageEnum.gif,
        messageReply: messageReply,
        isGroupChat: isGroupChat,
        senderName: senderUser.name,
        isForwarded: isForwarded,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void setChatMessageSeen({
    required BuildContext context,
    required String receiverUserId,
    required String messageId,
  }) async{
    try{
        //users -> sender id -> receiver id -> messages -> message id -> store message
        fireStore.collection('users').doc(firebaseAuth.currentUser!.uid).collection('chats').doc(receiverUserId).collection('messages')
            .doc(messageId).update({'seenBy': [firebaseAuth.currentUser!.uid, receiverUserId]});
        //users -> receiver id -> sender id -> messages -> message id -> store message
        fireStore.collection('users').doc(receiverUserId).collection('chats').doc(firebaseAuth.currentUser!.uid).collection('messages')
            .doc(messageId).update({'seenBy': [firebaseAuth.currentUser!.uid, receiverUserId]});
    }catch(e){
      showSnackBar(context: context, content: e.toString());
    }
  }

  void updateGroupChatMessageSeen(BuildContext context,List<String> seenBy, String groupId, String messageId) async{
    try {
      fireStore.collection('groups').doc(groupId).collection('chats').doc(messageId).update({
        'seenBy': seenBy,
      });
    }catch(e){
      showSnackBar(context: context, content: e.toString());
    }
  }

  void setUnSeenMessageCount({
    required BuildContext context,
    required String senderUserId,
    required String receiverUserId,
    required int unSeenMessageCount,
    required bool isGroupChat,
  }) async{
    try{
      if(isGroupChat){
        fireStore.collection('users').doc(firebaseAuth.currentUser!.uid).collection('groups').doc(receiverUserId).update({
          'unSeenMessageCount' : 0,
        });
      }else {
        fireStore.collection('users').doc(receiverUserId).collection('chats').doc(senderUserId)
            .update({'unSeenMessageCount': unSeenMessageCount});
      }
    }catch(e){
      showSnackBar(context: context, content: e.toString());
    }
  }

  void deleteMessagesForEveryone(List<Message> messages, ProviderRef ref, bool isGroupChat, bool isLastMessageSelected)async{
    String uid = firebaseAuth.currentUser!.uid;
    if(isGroupChat){
      if(isLastMessageSelected){
        fireStore.collection('groups').doc(messages[0].receiverId).update({
          'lastMessage' : '🚫 This message was deleted',
        });

        var groupData = await fireStore.collection('groups').doc(messages[0].receiverId).get();
        List<String> membersId = List<String>.from(groupData.data()!['membersUid']);
        for(var uid in membersId){
          fireStore.collection('users').doc(uid).collection('groups').doc(messages[0].receiverId).update({
            'lastMessage' : '🚫 This message was deleted',
          });
        }
      }
    }else{
      if(isLastMessageSelected){
        fireStore.collection('users').doc(messages[0].senderId).collection('chats').doc(messages[0].receiverId).update({
          'lastMessage' : '🚫 This message was deleted',
        });
        fireStore.collection('users').doc(messages[0].receiverId).collection('chats').doc(messages[0].senderId).update({
          'lastMessage' : '🚫 This message was deleted',
        });
      }
    }

    for(var message in messages){
      if(message.senderId == uid){
        if(message.type != MessageEnum.text) {
          ref.read(commonFireBaseStorageRepositoryProvider).deleteFileInFireStorage(
            'chat/${message.type.type}/${message.senderId}/${message.receiverId}/${message.messageId}'
          );
        }

        if(isGroupChat) {
          fireStore.collection('groups').doc(message.receiverId).collection('chats').doc(message.messageId).update({
            'text' : '🚫 This message was deleted',
            'type' : MessageEnum.text.type,
            'repliedMessage' : "",
            'isDeleted' : true,
          });
        }else{
          fireStore.collection('users').doc(message.senderId).collection('chats').doc(message.receiverId)
              .collection('messages').doc(message.messageId).update({
            'text' : '🚫 You deleted this message',
            'type' : MessageEnum.text.type,
            'repliedMessage' : "",
            'isDeleted' : true,
          });
          fireStore.collection('users').doc(message.receiverId).collection('chats').doc(message.senderId)
              .collection('messages').doc(message.messageId).update({
            'text' : '🚫 This message was deleted',
            'type' : MessageEnum.text.type,
            'repliedMessage' : "",
            'isDeleted' : true,
          });
        }
      }
    }
  }

  void deleteMessagesForMe(List<Message> messages, bool isGroupChat)async{
    String uid = firebaseAuth.currentUser!.uid;
    for(var message in messages){
      String receiverUid = message.senderId == uid ? message.receiverId : message.senderId;
      if(isGroupChat) {
        var messageData = await fireStore.collection('groups').doc(receiverUid).collection('chats').doc(message.messageId).get();
        List<String> deletedBy = List<String>.from(messageData.data()!['deletedBy']);
        deletedBy.add(uid);
        fireStore.collection('groups').doc(receiverUid).collection('chats').doc(message.messageId).update({
          'deletedBy' : deletedBy,
        });
      }else{
        fireStore.collection('users').doc(uid).collection('chats').doc(receiverUid)
            .collection('messages').doc(message.messageId).delete();
      }
    }
  }

  void updateLastMessage(Message messageData, bool isGroupChat)async{
    String uid = firebaseAuth.currentUser!.uid;
    String receiverUid = messageData.senderId == uid ? messageData.receiverId : messageData.senderId;
    String contactMsg = messageData.type == MessageEnum.text ? messageData.text : displayMessageForMessageType(messageData.type);
    if(isGroupChat){
      fireStore.collection('users').doc(uid).collection('groups').doc(receiverUid).update({
        'lastMessage' : contactMsg,
        'timeSent' : messageData.timeSent.millisecondsSinceEpoch,
      });
    }else{
      fireStore.collection('users').doc(uid).collection('chats').doc(receiverUid).update({
        'lastMessage' : contactMsg,
        'timeSent' : messageData.timeSent.millisecondsSinceEpoch,
      });
    }
  }

  void forwardMessage(List<ChatContact> chatList, List<Message> messages, BuildContext context, UserModel user){
    for(var message in messages) {
      MessageReply messageReply = MessageReply(message: "", isMe: true, messageEnum: MessageEnum.text, repliedTo: "", repliedMessageId: "");
      for(var chat in chatList){
        if(message.type == MessageEnum.text) {
          sendTextMessage(context: context, text: message.text, receiverUserId: chat.contactId, senderUser: user, messageReply: messageReply, isGroupChat: chat.isGroupChat, isForwarded: true, fcmToken: chat.fcmToken, receiverUserName: chat.name);
        }else if(message.type == MessageEnum.gif){
          sendGIFMessage(context: context, gifUrl: message.text, receiverUserId: chat.contactId, senderUser: user, messageReply: messageReply, isGroupChat: chat.isGroupChat, isForwarded: true, fcmToken: chat.fcmToken, receiverUserName: chat.name);
        }else{
          forwardFileMessage(context: context, imageUrl: message.text, receiverUserId: chat.contactId, senderUserData: user, messageEnum: message.type, messageReply: messageReply, isGroupChat: chat.isGroupChat, fcmToken: chat.fcmToken, receiverUserName: chat.name);
        }
      }
    }
  }

  void forwardFileMessage({
    required BuildContext context,
    required String imageUrl,
    required String receiverUserId,
    required String receiverUserName,
    required UserModel senderUserData,
    required MessageEnum messageEnum,
    required MessageReply? messageReply,
    required bool isGroupChat,
    required String? fcmToken
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String contactMsg = displayMessageForMessageType(messageEnum);

      _saveDataToContactsSubCollection(senderUserData: senderUserData, receiverUserName: receiverUserName, text: contactMsg
          , timeSent: timeSent, receiverUserId: receiverUserId, isGroupChat: isGroupChat, fcmToken: fcmToken);
      _saveMessageToMessageSubCollection(receiverUserId: receiverUserId, text: imageUrl, timeSent: timeSent, messageId: messageId, userName: senderUserData.name,
          receiverUserName: receiverUserName, messageType: messageEnum, messageReply: messageReply, isGroupChat: isGroupChat, senderName: senderUserData.name, isForwarded: true);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void setChatContactActivity(String contactId, bool isActive, bool isGroupChat){
    if(isGroupChat){
      fireStore.collection('users').doc(firebaseAuth.currentUser!.uid).collection('groups').doc(contactId).update({
        'isActiveOnScreen' : isActive,
      });
    }else{
      fireStore.collection('users').doc(firebaseAuth.currentUser!.uid).collection('chats').doc(contactId).update({
        'isActiveOnScreen' : isActive,
      });
    }
  }
}
