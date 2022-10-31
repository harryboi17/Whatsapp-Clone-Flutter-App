import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:search_page/search_page.dart';
import 'package:whatsapp_clone/features/group/widgets/select_contact_group.dart';

Future showCreateGroupSearchBar(BuildContext context, List<Contact> contacts){
  return showSearch(
    context: context,
    delegate: SearchPage(
      items: contacts,
      searchLabel: 'Search...',
      suggestion: Flex(
        direction: Axis.vertical,
        children: [ SelectContactsGroup(contactList: contacts,)],
      ),
      builder: (contact) => SelectGroupListTile(contact: contact),
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
