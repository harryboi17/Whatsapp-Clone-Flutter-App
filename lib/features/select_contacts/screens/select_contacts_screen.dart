import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/select_contacts/widgets/search_bar.dart';
import 'display_contacts_screens.dart';

class SelectContactScreen extends ConsumerWidget {
  static const String routeName = '/select-contact';
  final List<Contact> contacts;
  const SelectContactScreen({Key? key, required this.contacts}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select contact'),
        actions: [
          IconButton(
            onPressed: () => showContactSearchBar(context, ref, contacts),
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
      body: DisplayContactsScreen(
        ref: ref,
        contactList: contacts,
      ),
    );
  }
}
