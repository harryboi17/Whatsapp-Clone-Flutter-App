import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import '../../../model/call.dart';

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

    }catch(e){
      showSnackBar(context: context, content: e.toString());
    }
  }

  Stream<DocumentSnapshot> get callStream => fireStore.collection('call').doc(auth.currentUser!.uid).snapshots();
}