import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/search_bar.dart';

class DisplayContactsScreen extends StatelessWidget {
  final List<Contact> contactList;
  final WidgetRef ref;
  const DisplayContactsScreen({Key? key, required this.contactList, required this.ref}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
  }
}
