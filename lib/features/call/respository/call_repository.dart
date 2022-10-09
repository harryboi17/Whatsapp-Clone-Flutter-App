import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
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

  void makeCall({
    required Call senderCallData,
    required BuildContext context,
    required Call receiverCallData,
  }) async {
    try{
      await fireStore.collection('call').doc(senderCallData.callerId).set(senderCallData.toMap());
      await fireStore.collection('call').doc(senderCallData.receiverId).set(receiverCallData.toMap());

      Navigator.pushNamed(context, CallScreen.routeName, arguments: {
        'channelId' : senderCallData.callerId,
        'call' : senderCallData,
        'isGroupChat' : false,
      });

    }catch(e){
      showSnackBar(context: context, content: e.toString());
    }
  }
  void makeGroupCall({
    required Call senderCallData,
    required BuildContext context,
    required Call receiverCallData,
  }) async {
    try{
      await fireStore.collection('call').doc(senderCallData.callerId).set(senderCallData.toMap());

      var groupSnapshot = await fireStore.collection('groups').doc(senderCallData.receiverId).get();
      Group group = Group.fromMap(groupSnapshot.data()!);

      for(var id in group.membersUid) {
        await fireStore.collection('call').doc(id).set(
            receiverCallData.toMap());
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
}