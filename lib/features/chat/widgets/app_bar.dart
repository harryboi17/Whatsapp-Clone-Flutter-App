import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';
import 'package:whatsapp_clone/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_clone/features/chat/screens/forward_screen.dart';
import 'package:whatsapp_clone/features/chat/widgets/delete_message_dialog.dart';
import 'package:whatsapp_clone/features/chat/widgets/delete_message_dialog2.dart';
import 'package:whatsapp_clone/model/chat_contact.dart';
import '../../../common/utils/colors.dart';
import '../../../common/widgets/loader.dart';
import '../../../model/group.dart';
import '../../../model/message.dart';
import '../../../model/user_model.dart';
import '../../auth/controller/auth_controller.dart';
import '../../call/controller/call_controller.dart';

final chatScreenAppBarProvider = StateProvider<bool>((ref) => false);
final appBarMessageProvider = StateProvider<List<Message>>((ref) => []);
final isLastMessageSelectedProvider = StateProvider<bool>((ref) => false);

class ChatScreenAppBar extends ConsumerWidget with PreferredSizeWidget {
  final bool isGroupChat;
  final String uid;
  final String name;
  final String profilePic;

  ChatScreenAppBar({
    Key? key,
    required this.isGroupChat,
    required this.uid,
    required this.name,
    required this.profilePic,
  }) : super(key : key);

  void makeCall(WidgetRef ref, BuildContext context, bool isVideoCall) {
    ref.read(callControllerProvider).makeCall(context, name, uid, profilePic, isGroupChat, isVideoCall);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        AppBar(
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
                                ? snapshot.data!.userTyping.substring(0, 10) +
                                    ' is typing...'
                                : snapshot.data!.userTyping + ' is typing...'
                            : snapshot.data!.membersUid.length.toString() +
                                ' members',
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
              onPressed: () => makeCall(ref, context, true),
              icon: const Icon(Icons.video_call),
            ),
            IconButton(
              onPressed: () => makeCall(ref, context, false),
              icon: const Icon(Icons.call),
            ),
            IconButton(
              onPressed: (){},
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),

        Visibility(
          visible: ref.watch(chatScreenAppBarProvider),
          child: AppBar(
            leading: IconButton(
              onPressed: (){
                ref.read(chatScreenAppBarProvider.state).update((state) => false);
                ref.refresh(appBarMessageProvider);
                ref.refresh(isLastMessageSelectedProvider);
              },
              icon: const Icon(Icons.arrow_back),
            ),
            title: Text(ref.watch(appBarMessageProvider).length.toString()),
            actions: [
              Visibility(
                visible: ref.watch(appBarMessageProvider).length == 1,
                child: IconButton(
                    onPressed: () async {
                      Message message = ref.read(appBarMessageProvider)[0];
                      if(message.type == MessageEnum.text) {
                        await Clipboard.setData(ClipboardData(text: message.text));
                        Fluttertoast.showToast(
                          msg: "Message copied",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                        );
                      }else{
                        Fluttertoast.showToast(
                          msg: "Non text message cannot be copied",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                        );
                      }
                    },
                    icon: const Icon(Icons.copy),
                ),
              ),
              IconButton(
                  onPressed: (){
                    List<Message> messages = ref.read(appBarMessageProvider);
                    bool isAllMessageSentByMe = true;
                    String myUid = ref.read(authControllerProvider).uid();
                    for(var message in messages){
                      if(message.senderId != myUid){
                        isAllMessageSentByMe = false;
                      }
                    }
                    showDialog(
                        context: context,
                        builder: (context){
                          if(isAllMessageSentByMe) {
                            return DeleteMessageDialog(isGroupChat: isGroupChat,);
                          }
                          return DeleteMessageDialog2(isGroupChat: isGroupChat);
                        }
                    );
                  },
                  icon: const Icon(Icons.delete),
              ),
              IconButton(
                  onPressed: ()async{
                    List<ChatContact> contacts = await ref.read(chatControllerProvider).getSearchedContacts();
                    Navigator.pushNamed(context, ForwardScreen.routeName, arguments: {
                      'contacts' : contacts,
                    });
                  },
                  icon: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}