import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/widgets/error.dart';
import 'package:whatsapp_clone/common/widgets/loader.dart';
import 'package:whatsapp_clone/features/select_contacts/controller/select_contact_controller.dart';

final selectedGroupContacts = StateProvider<List<Contact>>((ref) => []);

class SelectContactsGroup extends ConsumerStatefulWidget {
  const SelectContactsGroup({Key? key}) : super(key: key);

  @override
  ConsumerState<SelectContactsGroup> createState() => _SelectContactsGroupState();
}

class _SelectContactsGroupState extends ConsumerState<SelectContactsGroup> {

  void selectContact(Contact contact){
    if(ref.read(selectedGroupContacts).contains(contact)){
      ref.read(selectedGroupContacts.state).update((state){
        state.remove(contact);
        return state;
      });
    }else{
      ref.read(selectedGroupContacts.state).update((state) => [...state, contact]);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(getContactsProvider).when(
        data: (contactList) => Expanded(
            child: ListView.builder(
              itemCount: contactList.length,
              itemBuilder: (context, index) {
                final contact = contactList[index];
                return InkWell(
                  onTap: () => selectContact(contact),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ListTile(
                      title: Text(contact.displayName),
                      leading: ref.read(selectedGroupContacts).contains(contactList[index])
                          ? IconButton(onPressed: () => selectContact(contact), icon : const Icon(Icons.done),)
                          : null
                    ),
                  ),
                );
              }
            ),
        ),
        error: (err, trace) => ErrorScreen(error: err.toString()),
        loading: () => const Loader()
    );
  }
}
