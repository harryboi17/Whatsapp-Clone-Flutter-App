import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/utils/colors.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/features/call/screens/call_log_screen.dart';
import 'package:whatsapp_clone/features/call/widgets/search_bar.dart';
import 'package:whatsapp_clone/features/chat/widgets/search_bar.dart';
import 'package:whatsapp_clone/features/group/screens/create_group_screen.dart';
import 'package:whatsapp_clone/features/select_contacts/controller/select_contact_controller.dart';
import 'package:whatsapp_clone/features/select_contacts/screens/select_contacts_screen.dart';
import 'package:whatsapp_clone/features/status/screens/confirm_status_screen.dart';
import 'package:whatsapp_clone/features/status/widgets/search_bar.dart';
import '../features/call/controller/call_controller.dart';
import '../features/chat/controller/chat_controller.dart';
import '../features/chat/widgets/contact_list.dart';
import '../features/notification/repository/notification_repository.dart';
import '../features/status/controller/status_controller.dart';
import '../features/status/screens/status_contacts_screen.dart';
import '../model/call.dart';
import '../model/chat_contact.dart';
import '../model/status_model.dart';

class MobileLayoutScreen extends ConsumerStatefulWidget {
  static const routeName = '/mobile-layout-screen';
  const MobileLayoutScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MobileLayoutScreen> createState() => _MobileLayoutScreenState();
}

class _MobileLayoutScreenState extends ConsumerState<MobileLayoutScreen> with WidgetsBindingObserver, TickerProviderStateMixin{
  late TabController tabBarController;
  late final List<Contact> contacts;

  @override
  void initState(){
    super.initState();
    tabBarController = TabController(length: 3, vsync: this);
    tabBarController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadContacts();
    });

    ref.read(notificationRepositoryProvider).storeNotificationToken();
    ref.read(notificationRepositoryProvider).initializeCloudMessaging(context);
  }

  void loadContacts()async{
    contacts = await ref.read(selectContactControllerProvider).getContact();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch(state){
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider).setUserState(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        ref.read(authControllerProvider).setUserState(false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: appBarColor,
          title: const Text(
            'WhatsApp',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.grey),
              onPressed: ()async {
                if(tabBarController.index == 0){
                  List<ChatContact> chatContacts = await ref.read(chatControllerProvider).getSearchedContacts();
                  showContactSearchBar(context, ref, chatContacts);
                }
                else if(tabBarController.index == 1){
                  List<UserStatus> statuses = await ref.read(statusControllerProvider).getSearchedStatus();
                  showStatusSearchBar(context, ref, statuses);
                }
                else{
                  List<Call> callLogs = await ref.read(callControllerProvider).getFutureCallLogs();
                  showCallSearchBar(context, ref, callLogs);
                }
              },
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey,),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Create Group'),
                  onTap: (){
                    Future(() => Navigator.pushNamed(context, CreateGroupScreen.routeName, arguments: {
                      'contacts' : contacts,
                    }));
                  },
                ),
              ],
            ),
          ],
          bottom: TabBar(
            controller: tabBarController,
            indicatorColor: tabColor,
            indicatorWeight: 4,
            labelColor: tabColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            tabs: const[
              Tab(text: 'CHATS',),
              Tab(text: 'STATUS',),
              Tab(text: 'CALLS',),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabBarController,
          children: const [
            ContactsList(),
            StatusContactsScreen(),
            CallLogs(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async{
            if(tabBarController.index == 0){
              Navigator.pushNamed(context, SelectContactScreen.routeName, arguments: {
                'contacts' : contacts,
              });
            }
            else if(tabBarController.index == 1){
              File? pickedImage = await pickImageFromGallery(context);
              if(pickedImage != null){
                if(!mounted) return;
                Navigator.pushNamed(context, ConfirmStatusScreen.routeName, arguments: pickedImage);
              }
            }
          },
          backgroundColor: tabColor,
          child: Icon(
            tabBarController.index == 0
                ? Icons.comment
                : tabBarController.index == 1
                  ? Icons.camera_alt_rounded
                  : Icons.add_call,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

}