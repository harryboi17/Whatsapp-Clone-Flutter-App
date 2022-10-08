import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/utils/colors.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/features/group/screens/create_group_screen.dart';
import 'package:whatsapp_clone/features/select_contacts/screens/select_contacts_screen.dart';
import 'package:whatsapp_clone/features/status/screens/confirm_status_screen.dart';

import '../features/chat/widgets/contact_list.dart';
import '../features/status/screens/status_contacts_screen.dart';

class MobileLayoutScreen extends ConsumerStatefulWidget {
  static const routeName = '/mobile-layout-screen';
  const MobileLayoutScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MobileLayoutScreen> createState() => _MobileLayoutScreenState();
}

class _MobileLayoutScreenState extends ConsumerState<MobileLayoutScreen> with WidgetsBindingObserver, TickerProviderStateMixin{
  late TabController tabBarController;

  @override
  void initState() {
    super.initState();
    tabBarController = TabController(length: 3, vsync: this);
    tabBarController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addObserver(this);
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
                onPressed: () {},
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey,),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text('Create Group'),
                    onTap: () => Future(() => Navigator.pushNamed(context, CreateGroupScreen.routeName)),
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
                Tab(
                  text: 'CHATS',
                ),
                Tab(
                  text: 'STATUS',
                ),
                Tab(
                  text: 'CALLS',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: tabBarController,
            children: const [
              ContactsList(),
              StatusContactsScreen(),
              Text('Calls'),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async{
              if(tabBarController.index == 0){
                Navigator.pushNamed(context, SelectContactScreen.routeName);
              }
              else if(tabBarController.index == 1){
                File? pickedImage = await pickImageFromGallery(context);
                if(pickedImage != null){
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
