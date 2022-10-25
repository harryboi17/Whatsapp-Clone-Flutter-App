import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_page/search_page.dart';
import 'package:whatsapp_clone/features/group/widgets/select_contact_group.dart';


void selectContact(WidgetRef ref ,Contact contact){
  if(ref.read(selectedGroupContacts).contains(contact)){
    ref.read(selectedGroupContacts.state).update((state){
      state.remove(contact);
      return state;
    });
  }else{
    ref.read(selectedGroupContacts.state).update((state) => [...state, contact]);
  }
}

Future showCreateGroupSearchBar(BuildContext context, WidgetRef ref, List<Contact> contacts){
  return showSearch(
    context: context,
    delegate: SearchPage(
      items: contacts,
      searchLabel: 'Search...',
      suggestion: Flex(
        direction: Axis.vertical,
        children:const [ SelectContactsGroup()],
      ),
      builder: (contact) => StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) setState) => InkWell(
          onTap: (){
            setState((){
              selectContact(ref, contact);
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: ListTile(
                title: Text(contact.displayName),
                leading: ref.read(selectedGroupContacts).contains(contact)
                    ? IconButton(onPressed: () => selectContact(ref, contact), icon : const Icon(Icons.done),)
                    : null
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
