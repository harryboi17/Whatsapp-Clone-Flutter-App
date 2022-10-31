import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_page/search_page.dart';
import 'package:whatsapp_clone/features/chat/screens/forward_screen.dart';
import 'package:whatsapp_clone/model/chat_contact.dart';
Future forwardingSearchBar(BuildContext context, WidgetRef ref, List<ChatContact> contacts) async {
  return showSearch(
    context: context,
    delegate: SearchPage(
      items: contacts,
      searchLabel: 'Search...',
      suggestion: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: ForwardingContactScreen(contacts: contacts,),
      ),
      builder: (contact) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: InkWell(
          onTap: () {},
          child: ChatListTile(chatContactData: contact,),
        ),
      ),
      filter: (contact) => [
        contact.name,
        contact.phoneNumber,
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
