import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../model/call.dart';
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
      String receiverProfilePic, bool isGroupChat) {
    ref.read(userDataAuthProvider).whenData((value) {
      String callId = const Uuid().v1();

      Call senderCallData = Call(
        callerId: auth.currentUser!.uid,
        callerName: value!.name,
        callerPic: value.profilePic,
        receiverId: receiverUid,
        receiverName: receiverName,
        receiverPic: receiverProfilePic,
        callId: callId,
        hasDialled: true,
      );

      Call receiverCallData = Call(
        callerId: auth.currentUser!.uid,
        callerName: value.name,
        callerPic: value.profilePic,
        receiverId: receiverUid,
        receiverName: receiverName,
        receiverPic: receiverProfilePic,
        callId: callId,
        hasDialled: false,
      );
      if (isGroupChat) {
        callRepository.makeGroupCall(senderCallData: senderCallData, context: context, receiverCallData: receiverCallData);
      } else {
        callRepository.makeCall(senderCallData: senderCallData, context: context, receiverCallData: receiverCallData);
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
}
//