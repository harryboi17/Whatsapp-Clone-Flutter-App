import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/model/chat_contact.dart';
import '../../../common/repository/firebase_storage_repository.dart';
import '../../../model/group.dart' as model;
import '../../../model/user_model.dart';

final groupRepositoryProvider = Provider((ref) => GroupRepository(
    fireStore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref,
  ),
);

class GroupRepository{
  final FirebaseFirestore fireStore;
  final FirebaseAuth auth;
  final ProviderRef ref;

  GroupRepository({
    required this.fireStore,
    required this.auth,
    required this.ref,
  });

  void createGroup({
    required BuildContext context,
    required String name,
    required File profilePic,
    required List<Contact> selectedContact,
  }) async {
    try{
      var groupId = const Uuid().v1();
      List<String> uids = [];
      String profileUrl = await ref.read(commonFireBaseStorageRepositoryProvider).storeFileToFirebase('group/$groupId', profilePic);
      for(int i = 0; i < selectedContact.length; i++){
        if(selectedContact[i].phones.isNotEmpty){
            var userCollection = await fireStore.collection('users')
                .where('phoneNumber', isEqualTo: selectedContact[i].phones[0].number.replaceAll(' ', ''))
                .get();

            if(userCollection.docs.isNotEmpty && userCollection.docs[0].exists
                && selectedContact[i].phones[0].number.replaceAll(' ', '') != auth.currentUser!.phoneNumber){
              UserModel userData = UserModel.fromMap(userCollection.docs[0].data());
              List<String> groupIds = userData.groupId;

              groupIds.add(groupId);
              uids.add(userData.uid);
              ChatContact groupModel = ChatContact(contactId: groupId, lastMessage: "", unSeenMessageCount: 0, isTyping: false, userTyping: "", timeSent: DateTime.now(),
                                                    name: name, profilePic: profileUrl, membersUid: [], phoneNumber: '', isGroupChat: true);
              await fireStore.collection('users').doc(userData.uid).collection('groups').doc(groupId).set(groupModel.toMap());
              await fireStore.collection('users').doc(userData.uid).update({
                'groupId' : groupIds,
              });
            }
        }
      }

      UserModel? currentUserData = await ref.read(authControllerProvider).getUserData();
      uids.add(currentUserData!.uid);
      List<String> groupIds = currentUserData.groupId;
      groupIds.add(groupId);
      ChatContact groupModel = ChatContact(contactId: groupId, lastMessage: "", unSeenMessageCount: 0, isTyping: false, userTyping: "", timeSent: DateTime.now(), name: name, profilePic: profileUrl, membersUid: [], phoneNumber: '', isGroupChat: true);
      await fireStore.collection('users').doc(auth.currentUser!.uid).collection('groups').doc(groupId).set(groupModel.toMap());
      await fireStore.collection('users').doc(currentUserData.uid).update({
        'groupId' : groupIds,
      });

      model.Group group = model.Group(
          senderId: auth.currentUser!.uid,
          name: name,
          groupId: groupId,
          lastMessage: '',
          groupPic: profileUrl,
          membersUid: uids,
          timeSent: DateTime.now(),
          isTyping: false,
          unSeenMessageCount: 0,
          userTyping: '',
      );

      await fireStore.collection('groups').doc(groupId).set(group.toMap());
      for(var membersId in uids){
        await fireStore.collection('users').doc(membersId).collection('groups').doc(groupId).update({
          'membersUid' : uids,
        });
      }
    }catch(e){
      showSnackBar(context: context, content: e.toString());
    }
  }
}