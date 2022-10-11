import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/widgets/loader.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/features/auth/repository/auth_repository.dart';
import 'package:whatsapp_clone/features/call/controller/call_controller.dart';
import 'package:whatsapp_clone/features/call/screens/call_pickup_screen.dart';
import 'package:whatsapp_clone/model/group.dart';
import '../../../common/utils/colors.dart';
import '../../../model/user_model.dart';
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
  })
      : super(key: key);

  void makeCall(WidgetRef ref, BuildContext context){
    ref.read(callControllerProvider).makeCall(context, name, uid, profilePic, isGroupChat);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CallPickupScreen(
      scaffold: Scaffold(
        appBar: AppBar(
          leadingWidth: 20,
          backgroundColor: appBarColor,
          title: isGroupChat
              ? StreamBuilder<Group>(
                  stream: ref.read(authControllerProvider).streamGroupDataById(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Loader();
                    }
                    return ListTile(
                      horizontalTitleGap: 10,
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(snapshot.data!.groupPic),
                        radius: 20,
                      ),
                      title: Text(name, style: const TextStyle(fontSize: 17)),
                      subtitle: Text(
                        snapshot.data!.isTyping
                            ? snapshot.data!.userTyping.length > 10
                                ? snapshot.data!.userTyping.substring(0,10) + ' is typing...'
                                : snapshot.data!.userTyping + ' is typing...'
                            : snapshot.data!.membersUid.length.toString() + ' members',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                        maxLines: 1,
                      ),
                    );
                  },
                )
              : StreamBuilder<UserModel>(
                  stream: ref.read(authControllerProvider).streamUserDataById(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Loader();
                    }
                    return ListTile(
                      horizontalTitleGap: 10,
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(snapshot.data!.profilePic),
                        radius: 20,
                      ),
                      title: Text(name, style: const TextStyle(fontSize: 17)),
                      subtitle: Text(
                        snapshot.data!.isOnline
                            ? snapshot.data!.isTyping
                                ? 'typing...'
                                : 'online'
                            : 'offline',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
          centerTitle: false,
          titleSpacing: 0,
          actions: [
            IconButton(
              onPressed: () => makeCall(ref, context),
              icon: const Icon(Icons.video_call),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.call),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
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
    );
  }
}
