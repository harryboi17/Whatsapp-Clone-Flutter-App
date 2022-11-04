import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/features/chat/widgets/app_bar.dart';
import '../../../common/utils/colors.dart';
import '../../../model/chat_contact.dart';
import '../controller/chat_controller.dart';
import '../widgets/forwarding_search_bar.dart';

final chatContactProvider = StateProvider<List<ChatContact>>((ref) => []);

class ForwardScreen extends ConsumerWidget {
  final List<ChatContact> contacts;
  const ForwardScreen({Key? key, required this.contacts}) : super(key: key);
  static const String routeName = '/forward-screen';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: ()async{
        ref.invalidate(chatContactProvider);
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: (){
              ref.invalidate(chatContactProvider);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('Forward to...'),
          actions: [
            IconButton(
                onPressed: () {
                  forwardingSearchBar(context, ref, contacts);
                },
                icon: const Icon(Icons.search)
            ),
          ],
        ),
        floatingActionButton: const  ForwardFloatingActionButton(),
        body: ForwardingContactScreen(contacts: contacts,),
      ),
    );
  }
}

class ForwardingContactScreen extends ConsumerWidget {
  final List<ChatContact> contacts;
  const ForwardingContactScreen({
    Key? key,
    required this.contacts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: contacts.length,
            itemBuilder: (context, index){
              ChatContact contact = contacts[index];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ChatListTile(chatContactData: contact),
                  ),
                  const Divider(color: dividerColor, indent: 85),
                ],
              );
            }
        ),
      ),
    );
  }
}

class ForwardFloatingActionButton extends ConsumerWidget {
  const ForwardFloatingActionButton({
    Key? key,
  }) : super(key: key);

  void reset(WidgetRef ref){
    ref.invalidate(chatContactProvider);
    ref.invalidate(appBarMessageProvider);
    ref.invalidate(chatScreenAppBarProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Visibility(
      visible: ref.watch(chatContactProvider).isNotEmpty,
      child: FloatingActionButton(
        onPressed: (){
          ref.read(chatControllerProvider).forwardMessage(context);
          reset(ref);
          Navigator.pop(context);
          Navigator.pop(context);
        },
        backgroundColor: tabColor,
        child: const Icon(Icons.send, size: 30, color: Colors.white,),
      ),
    );
  }
}

class ChatListTile extends ConsumerWidget {
  const ChatListTile({
    Key? key,
    required this.chatContactData,
  }) : super(key: key);

  final ChatContact chatContactData;

  void onTilePressed(ChatContact chatContact, WidgetRef ref){
    if(ref.read(chatContactProvider).contains(chatContact)){
      ref.read(chatContactProvider.notifier).update((state){
        state.remove(chatContact);
        return state;
      });
      ref.read(chatContactProvider.notifier).update((state) => [...state]);
    }else{
      ref.read(chatContactProvider.notifier).update((state) => [...state, chatContact]);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: () => onTilePressed(chatContactData, ref),
      title: Text(
        chatContactData.name,
        style: const TextStyle(
          fontSize: 18,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: Text(
          chatContactData.lastMessage,
          style: const TextStyle(fontSize: 15,),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      leading: Stack(
        children:[
          CircleAvatar(
            backgroundImage: NetworkImage(
                chatContactData.profilePic
            ),
            radius: 30,
          ),
          Visibility(
            visible: ref.watch(chatContactProvider).contains(chatContactData),
            child: Positioned(
              bottom: -1,
              left: 34,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.black
                  ),
                  shape: BoxShape.circle,
                  color: unSeenMessageColor,
                ),
                width: 25,
                height: 25,
              ),
            ),
          ),
          Visibility(
            visible: ref.watch(chatContactProvider).contains(chatContactData),
            child: Positioned(
              bottom: -14,
              left: 23,
              child: IconButton(
                onPressed: (){},
                icon: const Icon(
                  Icons.done_sharp,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ),
        ]
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(),
          Text(
            chatContactData.timeSent.isAfter(DateTime.now().subtract(const Duration(hours: 24)))
                ? DateFormat.jm().format(chatContactData.timeSent)
                : DateFormat('d/MM/yy').format(chatContactData.timeSent),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
