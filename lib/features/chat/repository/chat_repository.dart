import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';
import 'package:whatsapp_clone/common/provider/message_reply_provider.dart';
import 'package:whatsapp_clone/common/repository/firebase_storage_repository.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/model/chat_contact.dart';
import 'package:whatsapp_clone/model/message.dart';
import 'package:whatsapp_clone/model/user_model.dart';
import 'package:uuid/uuid.dart';

import '../../../model/group.dart';

final chatRepositoryProvider = Provider(
    (ref) => ChatRepository(FirebaseFirestore.instance, FirebaseAuth.instance));

class ChatRepository {
  final FirebaseFirestore fireStore;
  final FirebaseAuth firebaseAuth;

  ChatRepository(this.fireStore, this.firebaseAuth);

  Stream<List<ChatContact>> getChatContacts() {
    return fireStore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<ChatContact> contacts = [];
      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());
        var userData = await fireStore
            .collection('users')
            .doc(chatContact.contactId)
            .get();
        var user = UserModel.fromMap(userData.data()!);

        contacts.add(ChatContact(
          name: user.name,
          profilePic: user.profilePic,
          contactId: user.uid,
          timeSent: chatContact.timeSent,
          lastMessage: chatContact.lastMessage,
          isTyping: chatContact.isTyping,
          unSeenMessageCount: chatContact.unSeenMessageCount,
        ));
      }
      return contacts;
    });
  }

  Stream<List<GroupDataModel>> getChatGroups() {
    return fireStore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('groups')
        .snapshots()
        .asyncMap((event) async{
          List<GroupDataModel> groups = [];
          for(var groupIdData in event.docs){
            GroupDataModel groupDataModel = GroupDataModel.fromMap(groupIdData.data());
            // var groupData = await fireStore.collection('groups').doc(groupDataModel.groupId).get();
            // Group group = Group.fromMap(groupData.data()!);
            groups.add(groupDataModel);
          }
          return groups;
    });
  }

  Stream<List<Message>> getChatStream(String receiverUserId) {
    return fireStore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      return messages;
    });
  }
  Stream<List<GroupMessage>> getGroupChatStream(String groupId) {
    return fireStore
        .collection('groups')
        .doc(groupId)
        .collection('chats')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<GroupMessage> messages = [];
      for (var document in event.docs) {
        messages.add(GroupMessage.fromMap(document.data()));
      }
      return messages;
    });
  }

  void _saveDataToContactsSubCollection({
    required UserModel senderUserData,
    required UserModel? receiverUserData,
    required String text,
    required DateTime timeSent,
    required String receiverUserId,
    required bool isGroupChat,
  }) async {
    if(isGroupChat){
      await fireStore.collection('groups').doc(receiverUserId).update({
        'lastMessage' : text,
        'timeSent' : DateTime.now().millisecondsSinceEpoch,
      });

      var groupData = await fireStore.collection('groups').doc(receiverUserId).get();
      List<String> membersId = List<String>.from(groupData.data()!['membersUid']);
      for(var uid in membersId){
        await fireStore.collection('users').doc(uid).collection('groups').doc(receiverUserId).update({
          'lastMessage' : text,
          'timeSent' : DateTime.now().millisecondsSinceEpoch,
        });
      }
    }
    else {
      //users -> receiver user id => chats -> current user id -> set data
      var receiverChatContact = ChatContact(
        name: senderUserData.name,
        profilePic: senderUserData.profilePic,
        contactId: senderUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
        isTyping: false,
        unSeenMessageCount: 0,
      );

      await fireStore
          .collection('users')
          .doc(receiverUserId)
          .collection('chats')
          .doc(firebaseAuth.currentUser!.uid)
          .set(receiverChatContact.toMap());

      //users -> current user id => chats -> receiver user id -> set data
      var senderChatContact = ChatContact(
        name: receiverUserData!.name,
        profilePic: receiverUserData.profilePic,
        contactId: receiverUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
        isTyping: false,
        unSeenMessageCount: 0,
      );

      await fireStore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUserId)
          .set(senderChatContact.toMap());
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
  }) async {
    if(isGroupChat){
      final message = GroupMessage(
        senderId: firebaseAuth.currentUser!.uid,
        receiverId: receiverUserId,
        text: text,
        type: messageType,
        timeSent: timeSent,
        messageId: messageId,
        seenBy: [],
        repliedMessage: messageReply == null ? '' : messageReply.message,
        repliedTo: messageReply == null ? '' : messageReply.isMe ? userName : receiverUserName ?? '',
        repliedMessageType: messageReply == null ? MessageEnum.text : messageReply.messageEnum,
      );
      await fireStore.collection('groups').doc(receiverUserId).collection('chats').doc(messageId).set(message.toMap());

      var groupData = await fireStore.collection('groups').doc(receiverUserId).get();
      List<String> membersId = List<String>.from(groupData.data()!['membersUid']);
      for(var uid in membersId){
        if(uid != firebaseAuth.currentUser!.uid) {
          await fireStore.collection('users').doc(uid).collection('groups').doc(receiverUserId).update({
            'unSeenMessageCount' : FieldValue.increment(1),
          });
        }
      }
    }
    else {
      final message = Message(
        senderId: firebaseAuth.currentUser!.uid,
        receiverId: receiverUserId,
        text: text,
        type: messageType,
        timeSent: timeSent,
        messageId: messageId,
        isSeen: false,
        repliedMessage: messageReply == null ? '' : messageReply.message,
        repliedTo: messageReply == null ? '' : messageReply.isMe ? userName : receiverUserName ?? '',
        repliedMessageType: messageReply == null ? MessageEnum.text : messageReply.messageEnum,
      );
      //users -> sender id -> receiver id -> messages -> message id -> store message
      await fireStore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUserId)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());

      //users -> receiver id -> sender id -> messages -> message id -> store message
      await fireStore
          .collection('users')
          .doc(receiverUserId)
          .collection('chats')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());
    }
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String receiverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel? receiverUserData;

      if(!isGroupChat) {
        var userDataMap =
        await fireStore.collection('users').doc(receiverUserId).get();
        receiverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      var messageId = const Uuid().v1();

      _saveDataToContactsSubCollection(
        senderUserData: senderUser,
        receiverUserData: receiverUserData,
        // text: text.length > 30 ? "${text.substring(0,30)}..." : text,
        text: text,
        timeSent: timeSent,
        receiverUserId: receiverUserId,
        isGroupChat: isGroupChat,
      );
      _saveMessageToMessageSubCollection(
        receiverUserId: receiverUserId,
        text: text,
        timeSent: timeSent,
        messageId: messageId,
        userName: senderUser.name,
        receiverUserName: receiverUserData?.name,
        messageType: MessageEnum.text,
        messageReply: messageReply,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String receiverUserId,
    required UserModel senderUserData,
    required ProviderRef ref,
    required MessageEnum messageEnum,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String imageUrl = await ref
          .read(commonFireBaseStorageRepositoryProvider)
          .storeFileToFirebase(
              'chat/${messageEnum.type}/${senderUserData.uid}/$receiverUserId/$messageId',
              file);

      UserModel? receiverUserData;
      if(!isGroupChat) {
        var userDataMap =
        await fireStore.collection('users').doc(receiverUserId).get();
        receiverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      String contactMsg = displayMessageForMessageType(messageEnum);

      _saveDataToContactsSubCollection(senderUserData: senderUserData, receiverUserData: receiverUserData, text: contactMsg, timeSent: timeSent, receiverUserId: receiverUserId, isGroupChat: isGroupChat);
      _saveMessageToMessageSubCollection(receiverUserId: receiverUserId, text: imageUrl, timeSent: timeSent, messageId: messageId, userName: senderUserData.name, receiverUserName: receiverUserData?.name, messageType: messageEnum, messageReply: messageReply, isGroupChat: isGroupChat);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendGIFMessage({
    required BuildContext context,
    required String gifUrl,
    required String receiverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel? receiverUserData;

      if(!isGroupChat) {
        var userDataMap =
        await fireStore.collection('users').doc(receiverUserId).get();
        receiverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      var messageId = const Uuid().v1();

      _saveDataToContactsSubCollection(
        senderUserData: senderUser,
        receiverUserData: receiverUserData,
        text: '👾 GIF',
        timeSent: timeSent,
        receiverUserId: receiverUserId,
        isGroupChat: isGroupChat,
      );
      _saveMessageToMessageSubCollection(
        receiverUserId: receiverUserId,
        text: gifUrl,
        timeSent: timeSent,
        messageId: messageId,
        userName: senderUser.name,
        receiverUserName: receiverUserData?.name,
        messageType: MessageEnum.gif,
        messageReply: messageReply,
        isGroupChat: isGroupChat,
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
        await fireStore
            .collection('users')
            .doc(firebaseAuth.currentUser!.uid)
            .collection('chats')
            .doc(receiverUserId)
            .collection('messages')
            .doc(messageId)
            .update({'isSeen': true});

        //users -> receiver id -> sender id -> messages -> message id -> store message
        await fireStore
            .collection('users')
            .doc(receiverUserId)
            .collection('chats')
            .doc(firebaseAuth.currentUser!.uid)
            .collection('messages')
            .doc(messageId)
            .update({'isSeen': true});
    }catch(e){
      showSnackBar(context: context, content: e.toString());
    }
  }

  void updateGroupChatMessageSeen(BuildContext context,List<String> seenBy, String groupId, String messageId) async{
    try {
      await fireStore.collection('groups').doc(groupId).collection('chats').doc(messageId).update({
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
        await fireStore.collection('users').doc(firebaseAuth.currentUser!.uid).collection('groups').doc(receiverUserId).update({
          'unSeenMessageCount' : 0,
        });
      }else {
        await fireStore
            .collection('users')
            .doc(receiverUserId)
            .collection('chats')
            .doc(senderUserId)
            .update({'unSeenMessageCount': unSeenMessageCount});
      }
    }catch(e){
      showSnackBar(context: context, content: e.toString());
    }
  }

}
