import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/call/screens/call_pickup_screen.dart';
import '../widgets/app_bar.dart';
import '../widgets/bottom_chat_field.dart';
import '../widgets/chat_list.dart';

class MobileChatScreen extends ConsumerWidget {
  static const String routeName = '/mobile-chat-screen';
  final String name;
  final String uid;
  final bool isGroupChat;
  final int numberOfMembers;
  final String profilePic;

  const MobileChatScreen({Key? key,
      required this.name,
      required this.uid,
      required this.isGroupChat,
      required this.numberOfMembers,
      required this.profilePic
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CallPickupScreen(
      scaffold: WillPopScope(
        onWillPop: ()async{
          if(ref.read(chatScreenAppBarProvider) == true){
            ref.read(chatScreenAppBarProvider.state).update((state) => false);
            ref.refresh(appBarMessageProvider);
          }
          else{
            Navigator.pop(context);
          }
          return false;
        },
        child: Scaffold(
          appBar: ChatScreenAppBar(isGroupChat: isGroupChat, uid: uid, name: name, profilePic: profilePic),
          body: Column(
            children: [
              Expanded(
                child: ChatList(
                  receiverUserId: uid,
                  isGroupChat : isGroupChat,
                  numberOfMembers: numberOfMembers,
                ),
              ),
              BottomChatField(
                receiverUserId: uid,
                receiverName: name,
                isGroupChat : isGroupChat,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
