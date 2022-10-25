import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../model/call.dart';
import '../../../model/user_model.dart';
import '../../auth/controller/auth_controller.dart';
import '../respository/call_repository.dart';

final callControllerProvider = Provider((ref) {
  final callRepository = ref.read(callRepositoryProvider);
  return CallController(
    callRepository: callRepository,
    auth: FirebaseAuth.instance,
    ref: ref,
  );
});

class CallController {
  final FirebaseAuth auth;
  final CallRepository callRepository;
  final ProviderRef ref;

  CallController({
    required this.callRepository,
    required this.ref,
    required this.auth,
  });

  Stream<DocumentSnapshot> get callStream => callRepository.callStream;

  void makeCall(BuildContext context, String receiverName, String receiverUid,
      String receiverProfilePic, bool isGroupChat, bool isVideoCall) async{
    UserModel receiverUserModel;
    isGroupChat ? receiverUserModel = await ref.read(authControllerProvider).userData(auth.currentUser!.uid)
                : receiverUserModel = await ref.read(authControllerProvider).userData(receiverUid);
    ref.read(userDataAuthProvider).whenData((value) async {
      String callId = const Uuid().v1();
      String uid = isGroupChat ? auth.currentUser!.uid : receiverUid;
      var user = await ref.read(authControllerProvider).userData(uid);

      Call senderCallData = Call(
        callerId: auth.currentUser!.uid,
        callerName: value!.name,
        callerPic: value.profilePic,
        callerPhoneNumber: value.phoneNumber,
        receiverId: receiverUid,
        receiverName: receiverName,
        receiverPic: receiverProfilePic,
        receiverPhoneNumber: isGroupChat ? '' : receiverUserModel.phoneNumber,
        callId: callId,
        hasDialled: true,
        isGroupCall: isGroupChat,
        isMissedCall: false,
        isVideoCall: isVideoCall,
        callTime: DateTime.now(),
      );

      Call receiverCallData = Call(
        callerId: auth.currentUser!.uid,
        callerName: value.name,
        callerPic: value.profilePic,
        callerPhoneNumber: value.phoneNumber,
        receiverId: receiverUid,
        receiverName: receiverName,
        receiverPic: receiverProfilePic,
        receiverPhoneNumber: receiverUserModel.phoneNumber,
        callId: callId,
        hasDialled: false,
        isGroupCall: isGroupChat,
        isMissedCall: true,
        isVideoCall: isVideoCall,
        callTime: DateTime.now(),
      );
      if (isGroupChat) {
        if(isVideoCall) {
          callRepository.makeGroupVideoCall(senderCallData: senderCallData, context: context, receiverCallData: receiverCallData);
        }
      } else {
        if(isVideoCall) {
          callRepository.makeVideoCall(senderCallData: senderCallData, context: context, receiverCallData: receiverCallData);
        }else{
          callRepository.makeCall(user.phoneNumber, senderCallData, receiverCallData);
        }
      }
    });
  }

  void endCall({
    required String callerId,
    required String receiverId,
    required BuildContext context,
    required bool isGroupChat,
  }) {
    if(isGroupChat){
      callRepository.endGroupCall(callerId: callerId, receiverId: receiverId, context: context);
    }else {
      callRepository.endCall(callerId: callerId, receiverId: receiverId, context: context);
    }
  }

  void rejectCall(BuildContext context) {
      callRepository.rejectCall(receiverId: auth.currentUser!.uid, context: context);
  }

  void notifyPickingUpCall({
    required BuildContext context,
    required String callId,
  }) {
    callRepository.notifyPickingUpCall(context: context, callId: callId);
  }

  Future<List<Call>> getCallLogs(){
    return callRepository.getCallLogs(auth.currentUser!.uid);
  }
}
//