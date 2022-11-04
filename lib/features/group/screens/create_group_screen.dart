import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/group/widgets/search_bar.dart';
import '../../../common/utils/colors.dart';
import '../../../common/utils/utils.dart';
import '../controller/group_controller.dart';
import '../widgets/select_contact_group.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  static const String routeName = '/create-group';
  final List<Contact> contacts;
  const CreateGroupScreen({Key? key, required this.contacts}) : super(key: key);

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final TextEditingController groupNameController = TextEditingController();
  File? image;

  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void createGroup() {
    if (groupNameController.text.trim().isNotEmpty && image != null) {
      ref.read(groupControllerProvider).createGroup(
        context,
        groupNameController.text.trim(),
        image!,
        ref.read(selectedGroupContacts),
      );
      ref.read(selectedGroupContacts.notifier).update((state) => []);
      Navigator.pop(context);
    } else{
      showSnackBar(context: context, content: "A Group name and Image is necessary");
    }
  }

  @override
  void dispose() {
    super.dispose();
    groupNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        ref.invalidate(selectedGroupContacts);
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Group'),
          leading: IconButton(
            onPressed: (){
              ref.invalidate(selectedGroupContacts);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            IconButton(
              onPressed: () => showCreateGroupSearchBar(context, widget.contacts),
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Stack(
                children: [
                  image == null
                      ? const CircleAvatar(
                        backgroundImage: AssetImage('assets/empty_profile_image.jpg'),
                        radius: 64,
                      )
                      : CircleAvatar(
                        backgroundImage: FileImage(image!,),
                        radius: 64,
                      ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(
                        Icons.add_a_photo,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: groupNameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Group Name',
                  ),
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.fromLTRB(20,10,20,6),
                child: const Text(
                  'Select Contacts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SelectContactsGroup(contactList: widget.contacts,),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createGroup,
          backgroundColor: tabColor,
          child: const Icon(
            Icons.done,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}