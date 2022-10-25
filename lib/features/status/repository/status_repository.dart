import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/common/repository/firebase_storage_repository.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';

import '../../../model/status_model.dart';
import '../../../model/user_model.dart';

final statusRepositoryProvider = Provider((ref) => StatusRepository(fireStore: FirebaseFirestore.instance, auth: FirebaseAuth.instance, ref: ref,),)  ;

class StatusRepository{
  final FirebaseFirestore fireStore;
  final FirebaseAuth auth;
  final ProviderRef ref;

  StatusRepository({required this.fireStore, required this.auth, required this.ref});

  void uploadStatus({
    required String userName,
    required String profilePic,
    required String phoneNumber,
    required File statusImage,
    required BuildContext context,
  }) async{
    try{
      var statusId = const Uuid().v1();
      String uid = auth.currentUser!.uid;
      String imageUrl = await ref.read(commonFireBaseStorageRepositoryProvider).storeFileToFirebase('/status/$uid/$statusId', statusImage);

      List<Contact> contacts = [];
      if(await FlutterContacts.requestPermission()){
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
      List<String> uidWhoCanSee = [];
      for(int i = 0; i < contacts.length; i++){
        if(contacts[i].phones.isNotEmpty && contacts[i].phones[0].number.replaceAll(' ', '')  != auth.currentUser!.phoneNumber) {
          var userDataFireBase = await fireStore.collection('users').where(
              'phoneNumber',
              isEqualTo: contacts[i].phones[0].number.replaceAll(' ', '')
          ).get();

          if (userDataFireBase.docs.isNotEmpty) {
            var userData = UserModel.fromMap(userDataFireBase.docs[0].data());
            uidWhoCanSee.add(userData.uid);
            List<Map<String, dynamic>> statusIds = [];
            var statusIdsSnapshot =  await fireStore.collection('users').doc(userData.uid).collection('statuses').doc(uid).get();
            if(statusIdsSnapshot.exists){
              statusIds = List<Map<String, dynamic>>.from(statusIdsSnapshot.data()!['statusIds']);
              statusIds.add({
                'statusId' : statusId,
                'isSeen' : false
              });
              fireStore.collection('users').doc(userData.uid).collection('statuses').doc(uid).update({
                'statusIds' : statusIds
              });
            }
            else{
              statusIds = [{
                'statusId' : statusId,
                'isSeen' : false
              }];
              fireStore.collection('users').doc(userData.uid).collection('statuses').doc(uid).set({
                'userId' : uid,
                'statusIds' : statusIds
              });
            }
          }
        }
      }

      List<Map<String,dynamic>> statusIds = [];
      var statusIdsSnapshot =  await fireStore.collection('users').doc(uid).collection('statuses').doc(uid).get();
      if(statusIdsSnapshot.exists){
        statusIds = List<Map<String,dynamic>>.from(statusIdsSnapshot.data()!['statusIds']);
        statusIds.add({
          'statusId' : statusId,
          'isSeen' : false
        });
        fireStore.collection('users').doc(uid).collection('statuses').doc(uid).update({
          'statusIds' : statusIds
        });
      }
      else{
        statusIds = [{
          'statusId' : statusId,
          'isSeen' : false
        }];
        fireStore.collection('users').doc(uid).collection('statuses').doc(uid).set({
          'userId' : uid,
          'statusIds' : statusIds
        });
      }

      Status status = Status(
        uid: uid,
        photoUrl: imageUrl,
        createdAt: DateTime.now(),
        whoCanSee: uidWhoCanSee,
      );

      fireStore.collection('status').doc(statusId).set(status.toMap());
    }catch(e){
      showSnackBar(context: context, content: e.toString());
    }
  }

  Stream<List<UserStatus>> getStatus(BuildContext context, bool isSeenStatusColumn){
    return fireStore.collection('users').doc(auth.currentUser!.uid).collection('statuses').snapshots().asyncMap((event) async{
      List<UserStatus> userStatusData = [];
      List<UserStatus> seenUserStatusData = [];
      for(var document in event.docs){
        String userUid = document.data()['userId'];
        List<Map<String, dynamic>> statusIds = List<Map<String, dynamic>>.from(document.data()['statusIds']);
        var userData = await fireStore
            .collection('users')
            .doc(userUid)
            .get();
        var user = UserModel.fromMap(userData.data()!);

        List<String> photoUrl = [];
        List<String> listStatusIds = [];
        List<bool> isSeenStatus = [];
        int seenStatusIdCount = 0;
        DateTime lastUploadedStatusTime = DateTime(0);
        if(statusIds.isNotEmpty && user.uid != auth.currentUser!.uid){
          for(var statusId in statusIds){
            var statusDataSnapshot = await fireStore.collection('status').doc(statusId['statusId']).get();
            Status statusData = Status.fromMap(statusDataSnapshot.data()!);
            if(statusData.createdAt.isAfter(DateTime.now().subtract(const Duration(hours: 24)))) {
              photoUrl.add(statusData.photoUrl);
              listStatusIds.add(statusId['statusId']);
              isSeenStatus.add(statusId['isSeen']);
              if(statusData.createdAt.isAfter(lastUploadedStatusTime)) {
                lastUploadedStatusTime = statusData.createdAt;
              }
              if(statusId['isSeen']){seenStatusIdCount += 1;}
            }
          }
          if(photoUrl.isNotEmpty && listStatusIds.isNotEmpty){
            UserStatus userStatus = UserStatus(name: user.name, profilePic: user.profilePic, photoUrl: photoUrl, statusId: listStatusIds,
                uid: userUid, isSeenStatus: isSeenStatus, lastUploadedStatusTime: lastUploadedStatusTime, phoneNumber: user.phoneNumber);
            if(seenStatusIdCount != listStatusIds.length) {
              userStatusData.add(userStatus);
            }
            else{
              seenUserStatusData.add(userStatus);
            }
          }
        }
      }
      if(isSeenStatusColumn) {
        return seenUserStatusData;
      } else {
        return userStatusData;
      }
    });
  }

  Stream<UserStatus> getMyStatus(BuildContext context){
    return fireStore.collection('users').doc(auth.currentUser!.uid).collection('statuses').doc(auth.currentUser!.uid).snapshots().asyncMap((event) async{
      var userData = await fireStore.collection('users').doc(auth.currentUser!.uid).get();
      var user = UserModel.fromMap(userData.data()!);
      List<Map<String, dynamic>> statusIds = List<Map<String, dynamic>>.from(event.data()!['statusIds']);

      List<String> photoUrl = [];
      List<String> listStatusIds = [];
      List<bool> isSeenStatus = [];
      DateTime lastUploadedStatusTime = DateTime(0);
      for(var statusId in statusIds){
        var statusDataSnapshot = await fireStore.collection('status').doc(statusId['statusId']).get();
        Status statusData = Status.fromMap(statusDataSnapshot.data()!);
        if(statusData.createdAt.isAfter(DateTime.now().subtract(const Duration(hours: 24)))) {
          photoUrl.add(statusData.photoUrl);
          listStatusIds.add(statusId['statusId']);
          isSeenStatus.add(statusId['isSeen']);
          if(statusData.createdAt.isAfter(lastUploadedStatusTime)) {
            lastUploadedStatusTime = statusData.createdAt;
          }
        }
      }
      UserStatus userStatus = UserStatus(name: user.name, profilePic: user.profilePic, photoUrl: photoUrl, statusId: listStatusIds,
          uid: auth.currentUser!.uid, isSeenStatus: isSeenStatus, lastUploadedStatusTime: lastUploadedStatusTime, phoneNumber: user.phoneNumber);

      return userStatus;
    });
  }

  void updateIsSeen(String uid, String statusId) async{
    var dataSnapshot =  await fireStore.collection('users').doc(auth.currentUser!.uid).collection('statuses').doc(uid).get();
    List<Map<String, dynamic>> statusIds = List<Map<String, dynamic>>.from(dataSnapshot.data()!['statusIds']);
    Map<String, dynamic> toFindId = {
      'isSeen' : false,
      'statusId' : statusId,
    };

    int index = -1;
    for(int i = 0; i < statusIds.length; i++){
      if(mapEquals(statusIds[i], toFindId)){
        index = i;
        break;
      }
    }

    if(index != -1) {
      statusIds[index]['isSeen'] = true;
      await fireStore.collection('users').doc(auth.currentUser!.uid).collection(
          'statuses').doc(uid).update({
        'statusIds': statusIds,
      });
    }
  }

  Future<List<UserStatus>> getSearchedStatus() async{
     var statusDataSnapshot = await fireStore.collection('users').doc(auth.currentUser!.uid).collection('statuses').get();
     List<UserStatus> userStatusData = [];
     for(var document in statusDataSnapshot.docs){
       String userUid = document.data()['userId'];
       List<Map<String, dynamic>> statusIds = List<Map<String, dynamic>>.from(document.data()['statusIds']);
       var userData = await fireStore
           .collection('users')
           .doc(userUid)
           .get();
       var user = UserModel.fromMap(userData.data()!);
       List<String> photoUrl = [];
       List<String> listStatusIds = [];
       List<bool> isSeenStatus = [];
       DateTime lastUploadedStatusTime = DateTime(0);
       if(statusIds.isNotEmpty && user.uid != auth.currentUser!.uid){
         for(var statusId in statusIds){
           var statusDataSnapshot = await fireStore.collection('status').doc(statusId['statusId']).get();
           Status statusData = Status.fromMap(statusDataSnapshot.data()!);
           if(statusData.createdAt.isAfter(DateTime.now().subtract(const Duration(hours: 24)))) {
             photoUrl.add(statusData.photoUrl);
             listStatusIds.add(statusId['statusId']);
             isSeenStatus.add(statusId['isSeen']);
             if(statusData.createdAt.isAfter(lastUploadedStatusTime)) {
               lastUploadedStatusTime = statusData.createdAt;
             }
           }
         }
         if(photoUrl.isNotEmpty && listStatusIds.isNotEmpty){
           UserStatus userStatus = UserStatus(name: user.name, profilePic: user.profilePic, photoUrl: photoUrl, statusId: listStatusIds,
               uid: userUid, isSeenStatus: isSeenStatus, lastUploadedStatusTime: lastUploadedStatusTime, phoneNumber: user.phoneNumber);
           userStatusData.add(userStatus);
         }
       }
     }
     return userStatusData;
  }
}