import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import '../../../model/call.dart';
import '../../../model/group.dart';
import '../screens/call_screen.dart';

final callRepositoryProvider = Provider((ref) => CallRepository(
  fireStore: FirebaseFirestore.instance,
  auth: FirebaseAuth.instance,
),
);

class CallRepository{
  final FirebaseFirestore fireStore;
  final FirebaseAuth auth;

  CallRepository({
    required this.fireStore,
    required this.auth,
  });

  void makeVideoCall({
    required Call senderCallData,
    required BuildContext context,
    required Call receiverCallData,
  }) async {
    try{
      await fireStore.collection('call').doc(senderCallData.callerId).set(senderCallData.toMap());
      await fireStore.collection('call').doc(senderCallData.receiverId).set(receiverCallData.toMap());

      await fireStore.collection('users').doc(senderCallData.callerId).collection('callLog').doc(senderCallData.callId).set(senderCallData.toMap());
      await fireStore.collection('users').doc(receiverCallData.receiverId).collection('callLog').doc(receiverCallData.callId).set(receiverCallData.toMap());

      Navigator.pushNamed(context, CallScreen.routeName, arguments: {
        'channelId' : senderCallData.callerId,
        'call' : senderCallData,
        'isGroupChat' : false,
      });

    }catch(e){
      showSnackBar(context: context, content: e.toString());
    }
  }
  void makeGroupVideoCall({
    required Call senderCallData,
    required BuildContext context,
    required Call receiverCallData,
  }) async {
    try{
      await fireStore.collection('call').doc(senderCallData.callerId).set(senderCallData.toMap());
      await fireStore.collection('users').doc(senderCallData.callerId).collection('callLog').doc(senderCallData.callId).set(senderCallData.toMap());

      var groupSnapshot = await fireStore.collection('groups').doc(senderCallData.receiverId).get();
      Group group = Group.fromMap(groupSnapshot.data()!);

      for(var id in group.membersUid) {
        if(id != senderCallData.callerId) {
          await fireStore.collection('call').doc(id).set(
            receiverCallData.toMap());
          await fireStore.collection('users').doc(id).collection('callLog').doc(receiverCallData.callId).set(receiverCallData.toMap());
        }
      }

      Navigator.pushNamed(context, CallScreen.routeName, arguments: {
        'channelId' : senderCallData.callerId,
        'call' : senderCallData,
        'isGroupChat' : true,
      });

    }catch(e){
      showSnackBar(context: context, content: e.toString());
    }
  }

  void makeCall(String phoneNumber, Call senderCallData, Call receiverCallData) async{
    await fireStore.collection('users').doc(senderCallData.callerId).collection('callLog').doc(senderCallData.callId).set(senderCallData.toMap());
    await fireStore.collection('users').doc(receiverCallData.receiverId).collection('callLog').doc(receiverCallData.callId).set(receiverCallData.toMap());
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }

  Stream<DocumentSnapshot> get callStream => fireStore.collection('call').doc(auth.currentUser!.uid).snapshots();

  void endCall({
    required String callerId,
    required String receiverId,
    required BuildContext context,
  }) async {
    try{
      await fireStore.collection('call').doc(callerId).delete();
      await fireStore.collection('call').doc(receiverId).delete();
      Navigator.pop(context);
    }catch(e){
      showSnackBar(context: context, content: e.toString());
    }
  }

  void endGroupCall({
    required String callerId,
    required String receiverId,
    required BuildContext context,
  }) async {
    try{
      await fireStore.collection('call').doc(callerId).delete();

      var groupSnapshot = await fireStore.collection('groups').doc(receiverId).get();
      Group group = Group.fromMap(groupSnapshot.data()!);
      for(var id in group.membersUid) {
        await fireStore.collection('call').doc(id).delete();
      }

      Navigator.pop(context);
    }catch(e){
      showSnackBar(context: context, content: e.toString());
    }
  }

  void rejectCall({
    required String receiverId,
    required BuildContext context,
  }) async {
    try{
      await fireStore.collection('call').doc(receiverId).delete();
    }catch(e){
      showSnackBar(context: context, content: e.toString());
    }
  }

  void notifyPickingUpCall({
    required BuildContext context,
    required String callId,
  }) async{
    await fireStore.collection('users').doc(auth.currentUser!.uid).collection('callLog').doc(callId).update({
      'isMissedCall' : false,
    });
  }

  Future<List<Call>> getCallLogs(String uid) async{
    List<Call> callLogs = [];
    var callSnapshot = await fireStore.collection('users').doc(uid).collection('callLog').orderBy('callTime', descending: true).get();
    for(var doc in callSnapshot.docs){
      Call callData = Call.fromMap(doc.data());
      callLogs.add(callData);
    }
    return callLogs;
  }
}