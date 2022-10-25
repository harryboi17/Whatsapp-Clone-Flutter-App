import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/error.dart';
import '../../../common/widgets/loader.dart';
import '../controller/select_contact_controller.dart';
import '../widgets/search_bar.dart';
class DisplayContactsScreen extends StatelessWidget {
  final WidgetRef ref;
  final Function setContacts;
  const DisplayContactsScreen({Key? key, required this.ref, required this.setContacts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  ref.watch(getContactsProvider).when(
      data: (contactList) {
        setContacts(contactList);
        return ListView.builder(
          itemCount: contactList.length,
          itemBuilder: (context, index) {
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
                  leading: contact.photo == null ?
                  const CircleAvatar(
                    backgroundImage: AssetImage(
                        'assets/empty_profile_image.jpg'),
                  )
                      : CircleAvatar(
                    backgroundImage: MemoryImage(contact.photo!),
                  ),
                ),
              ),
            );
          },
        );
      },
      error: (err, trace) => ErrorScreen(error: err.toString()),
      loading: () => const Loader(),
    );
  }
}
