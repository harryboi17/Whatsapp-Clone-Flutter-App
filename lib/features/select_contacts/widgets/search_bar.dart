import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_page/search_page.dart';
import 'package:whatsapp_clone/features/select_contacts/screens/display_contacts_screens.dart';
import 'package:whatsapp_clone/features/select_contacts/screens/select_contacts_screen.dart';

import '../controller/select_contact_controller.dart';

void selectContact(WidgetRef ref, Contact selectedContact, BuildContext context){
  ref.read(selectContactControllerProvider).selectContact(selectedContact, context);
}

Future showContactSearchBar(BuildContext context, WidgetRef ref, List<Contact> contacts) async {
  return showSearch(
    context: context,
    delegate: SearchPage(
      items: contacts,
      searchLabel: 'Search...',
      suggestion: DisplayContactsScreen(ref: ref, setContacts: (List<Contact> contactList){},),
      builder: (contact) => InkWell(
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
            leading: contact.photo == null
                ? const CircleAvatar(
                    backgroundImage: AssetImage(
                        'assets/empty_profile_image.jpg'),
                )
                : CircleAvatar(
                  backgroundImage: MemoryImage(contact.photo!),
                ),
          ),
        ),
      ),
      filter: (contact) => [
        contact.displayName,
        if(contact.phones.isNotEmpty)
          contact.phones[0].number.replaceAll(' ', ''),
      ],
      failure: const Center(
        child: Text(
          'No results found',
          style: TextStyle(color: Colors.white54),
        ),
      ),
    ),
  );
}
