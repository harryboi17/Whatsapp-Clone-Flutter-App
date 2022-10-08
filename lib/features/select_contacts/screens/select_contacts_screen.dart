import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/widgets/error.dart';
import 'package:whatsapp_clone/features/select_contacts/controller/select_contact_controller.dart';

import '../../../common/widgets/loader.dart';

class SelectContactScreen extends ConsumerWidget {
  static const String routeName = '/select-contact';
  const SelectContactScreen({Key? key}) : super(key: key);

  void selectContact(WidgetRef ref, Contact selectedContact, BuildContext context){
    ref.read(selectContactControllerProvider).selectContact(selectedContact, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select contact'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
            ),
          ),
        ],
      ),
      body: ref.watch(getContactsProvider).when(
          data: (contactList) => ListView.builder(
            itemCount: contactList.length,
            itemBuilder: (context, index){
              final contact = contactList[index];
              return InkWell(
                onTap: () => selectContact(ref, contact, context),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    title: Text(
                      contact.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    leading: contact.photo == null?
                        const CircleAvatar(
                          backgroundImage: AssetImage('assets/empty_profile_image.jpg'),
                        )
                        : CircleAvatar(
                            backgroundImage: MemoryImage(contact.photo!),
                          ),
                  ),
                ),
              );
            },
          ),
          error: (err, trace) => ErrorScreen(error: err.toString()),
          loading: () => const Loader(),
      ),
    );
  }
}
