import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedGroupContacts = StateProvider<List<Contact>>((ref) => []);

class SelectContactsGroup extends StatelessWidget {
  final List<Contact> contactList;
  const SelectContactsGroup({Key? key, required this.contactList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          itemCount: contactList.length,
          itemBuilder: (context, index) {
            final contact = contactList[index];
            return SelectGroupListTile(contact: contact);
          }
      ),
    );
  }
}

class SelectGroupListTile extends ConsumerWidget {
  const SelectGroupListTile({
    Key? key,
    required this.contact,
  }) : super(key: key);

  final Contact contact;
  void selectContact(Contact contact, WidgetRef ref) {
    if(ref.read(selectedGroupContacts).contains(contact)){
      ref.read(selectedGroupContacts.notifier).update((state){
        state.remove(contact);
        return state;
      });
      ref.read(selectedGroupContacts.notifier).update((state) => [...state]);
    }else{
      ref.read(selectedGroupContacts.notifier).update((state) => [...state, contact]);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => selectContact(contact, ref),
      child: Padding(
        padding: const EdgeInsets.only(left: 6),
        child: ListTile(
            title: Text(contact.displayName),
            leading: ref.watch(selectedGroupContacts).contains(contact)
                ? IconButton(onPressed: () => selectContact(contact, ref), icon : const Icon(Icons.done),)
                : null
        ),
      ),
    );
  }
}
