import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';

import '../../../model/user_model.dart';
import '../../chat/screens/mobile_chat_screen.dart';

final selectContactsRepositoryProvider = Provider((ref) => SelectContactRepository(fireStore: FirebaseFirestore.instance));
class SelectContactRepository{
  final FirebaseFirestore fireStore;

  SelectContactRepository({required this.fireStore});

  Future<List<Contact>> getContacts() async{
    List<Contact> contacts = [];
    try{
      if(await FlutterContacts.requestPermission()){
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
    } catch(e){
      debugPrint(e.toString());
    }
    return contacts;
  }

  void selectContact(Contact selectedContact, BuildContext context) async{
    try{
      var userCollection = await fireStore.collection('users').get();
      bool isFound = false;

      for(var document in userCollection.docs){
        var userData = UserModel.fromMap(document.data());
        String selectedPhoneNumber = selectedContact.phones[0].number.replaceAll(' ', '');
        if(selectedPhoneNumber == userData.phoneNumber){
          isFound = true;
          Navigator.pushNamed(
              context,
              MobileChatScreen.routeName,
              arguments: {
                'name' : selectedContact.displayName,
                'uid' : userData.uid,
                'isGroupChat' : false,
                'numberOfMembers' : 1,
                'profilePic' : userData.profilePic,
              }
          );
        }
      }

      if(!isFound){
        showSnackBar(context: context, content: "This number doesn't exist on this app");
      }
    }catch(e){
      showSnackBar(context: context, content: e.toString());
    }
  }

}