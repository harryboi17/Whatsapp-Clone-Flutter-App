import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/screens/otp_screen.dart';
import 'package:whatsapp_clone/features/auth/screens/user_information.dart';
import 'package:whatsapp_clone/common/repository/firebase_storage_repository.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/model/user_model.dart';
import 'package:whatsapp_clone/screens/mobile_layout_screen.dart';

import '../../../model/group.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(
      auth: FirebaseAuth.instance,
      fireStore: FirebaseFirestore.instance,
    ));

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore fireStore;

  AuthRepository({required this.auth, required this.fireStore});

  Future<UserModel?> getCurrentUserData() async{
    var userData = await fireStore.collection('users').doc(auth.currentUser?.uid).get();
    UserModel? user;
    if(userData.data() != null){
      user = UserModel.fromMap(userData.data()!);
    }
    return user;
  }

  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          throw Exception(e.message);
        },
        codeSent: (String verificationId, int? resendToken) async {
          Navigator.pushNamed(
            context,
            OTPScreen.routeName,
            arguments: verificationId,
          );
        },
        codeAutoRetrievalTimeout: (String verificationID) {},
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: context, content: e.message!);
    }
  }

  void verifyOTP(
      {required BuildContext context,
      required String verificationId,
      required String userOTP}) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOTP,
      );
      await auth.signInWithCredential(credential);
      Navigator.pushNamedAndRemoveUntil(context, UserInformationScreen.routeName, (route) => false);
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: context, content: e.message!);
    }
  }

  Future<void> saveUserDataToFirebase({required String name, required File? profilePic, required ProviderRef ref, required BuildContext context,}) async {
    try{
      String uid = auth.currentUser!.uid;
      String photoUrl = 'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';

      profilePic ??= await getImageFileFromAssets('empty_profile_image.jpg');
      photoUrl = await ref.read(commonFireBaseStorageRepositoryProvider).storeFileToFirebase('profilePic/$uid', profilePic);

      var user = UserModel(name: name, uid: uid, profilePic: photoUrl, isOnline: true, phoneNumber: auth.currentUser!.phoneNumber!, groupId: [], isTyping: false);
      await fireStore.collection('users').doc(uid).set(user.toMap());
      Navigator.pushNamedAndRemoveUntil(context, MobileLayoutScreen.routeName, (route) => false);
    }
    catch(e){
      showSnackBar(context: context, content: e.toString());
    }
  }

  userData(String userId){
    return fireStore.collection('users').doc(userId).snapshots().map(
            (event) => UserModel.fromMap(event.data()!)
    );
  }

  Future<UserModel> userModelData(String uid) async{
    var data =  await fireStore.collection('users').doc(uid).get();
    UserModel userData = UserModel.fromMap(data.data()!);
    return userData;
  }

  groupData(String groupId){
    return fireStore.collection('groups').doc(groupId).snapshots().map(
            (event) => Group.fromMap(event.data()!)
    );
  }

  void setUserState(bool isOnline) async{
    await fireStore.collection('users').doc(auth.currentUser!.uid).update({
      'isOnline': isOnline,
    });
  }

  void setUserTyingStatus(bool isTyping, String userId, bool isGroupChat) async{
    if(isGroupChat){
      var currentUserData = await fireStore.collection('users').doc(auth.currentUser!.uid).get();
      UserModel userData = UserModel.fromMap(currentUserData.data()!);
      await fireStore.collection('groups').doc(userId).update({
        'isTyping' : isTyping,
        'userTyping' : userData.name
      });

      var groupData = await fireStore.collection('groups').doc(userId).get();
      List<String> membersId = List<String>.from(groupData.data()!['membersUid']);
      for(var uid in membersId){
        await fireStore.collection('users').doc(uid).collection('groups').doc(userId).update({
          'isTyping' : isTyping,
          'userTyping' : userData.name
        });
      }
    }else {
      await fireStore.collection('users').doc(auth.currentUser!.uid).update({
        'isTyping': isTyping,
      });
      await fireStore.collection('users').doc(userId).collection('chats').doc(
          auth.currentUser!.uid).update({
        'isTyping': isTyping,
      });
    }
  }
}
