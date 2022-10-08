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
  List<int> selectedContactsIndex = [];

  void selectContact(int index, Contact contact){
    if(selectedContactsIndex.contains(index)){
      selectedContactsIndex.remove(index);
      ref.read(selectedGroupContacts.state).update((state){
        state.remove(contact);
        return state;
      });
    }else{
      selectedContactsIndex.add(index);
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
                  onTap: () => selectContact(index, contact),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ListTile(
                      title: Text(contact.displayName),
                      leading: selectedContactsIndex.contains(index)
                          ? IconButton(onPressed: (){}, icon : const Icon(Icons.done),)
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
