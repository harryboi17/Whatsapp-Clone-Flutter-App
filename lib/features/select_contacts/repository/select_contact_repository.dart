import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import '../../../model/chat_contact.dart';
import '../../../model/user_model.dart';
import '../../chat/screens/mobile_chat_screen.dart';

final selectContactsRepositoryProvider = Provider((ref) => SelectContactRepository(fireStore: FirebaseFirestore.instance, auth: FirebaseAuth.instance));
class SelectContactRepository{
  final FirebaseFirestore fireStore;
  final FirebaseAuth auth;

  SelectContactRepository({required this.fireStore, required this.auth});

  Future<List<Contact>> getContacts() async{
    List<Contact> contacts = [];
    try{
      if(await Permission.contacts.request().isGranted){
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
    } catch(e){
      debugPrint(e.toString());
    }
    return contacts;
  }

  void selectContact(Contact selectedContact, BuildContext context, UserModel myData) async{
    try{
      var userCollection = await fireStore.collection('users').get();
      bool isFound = false;

      for(var document in userCollection.docs){
        var userData = UserModel.fromMap(document.data());
        String selectedPhoneNumber = selectedContact.phones[0].number.replaceAll(' ', '');
        if(selectedPhoneNumber == userData.phoneNumber){
          isFound = true;
          var chatDataSnapShot = await fireStore.collection('users').doc(myData.uid).collection('chats').doc(userData.uid).get();
          ChatContact? chatData = chatDataSnapShot.data() == null ? null : ChatContact.fromMap(chatDataSnapShot.data()!);
          //users -> receiver user id => chats -> current user id -> set data
          var receiverChatContact = ChatContact(
            name: myData.name,
            profilePic: myData.profilePic,
            contactId: myData.uid,
            timeSent: chatData == null ? DateTime.now() : chatData.timeSent,
            lastMessage: chatData == null ? '' : chatData.lastMessage,
            isTyping: false,
            unSeenMessageCount: 0,
            phoneNumber: userData.phoneNumber,
            isGroupChat: false,
            membersUid: [myData.uid],
            userTyping: "",
            fcmToken: myData.token,
            isActiveOnScreen: false,
          );
          fireStore.collection('users').doc(userData.uid).collection('chats').doc(myData.uid).set(receiverChatContact.toMap());

          //users -> current user id => chats -> receiver user id -> set data
          var senderChatContact = ChatContact(
            // name: selectedContact.displayName,
            name: userData.name,
            profilePic: userData.profilePic,
            contactId: userData.uid,
            timeSent: chatData == null ? DateTime.now() : chatData.timeSent,
            lastMessage: chatData == null ? '' : chatData.lastMessage,
            isTyping: false,
            unSeenMessageCount: 0,
            phoneNumber: userData.phoneNumber,
            isGroupChat: false,
            membersUid: [userData.uid],
            userTyping: "",
            fcmToken: userData.token,
            isActiveOnScreen: true,
          );
          fireStore.collection('users').doc(myData.uid).collection('chats').doc(userData.uid).set(senderChatContact.toMap());
          Navigator.pushReplacementNamed(context, MobileChatScreen.routeName, arguments: {
                'name' : selectedContact.displayName,
                'uid' : userData.uid,
                'isGroupChat' : false,
                'numberOfMembers' : 1,
                'profilePic' : userData.profilePic,
                'fcmToken' : userData.token,
              }
          );
        }
      }

      if(!isFound){
        showSnackBar(context: context, content: "Either this number doesn't exist on this app"
            " or Contact saved on your phone isn't initialized with country code (ex. +91)");
      }
    }catch(e){
      showSnackBar(context: context, content: e.toString());
    }
  }

}