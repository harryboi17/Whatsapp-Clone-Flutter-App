import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:search_page/search_page.dart';
import 'package:whatsapp_clone/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_clone/features/chat/widgets/contact_list.dart';
import 'package:whatsapp_clone/model/chat_contact.dart';

import '../../../common/utils/colors.dart';
import '../screens/mobile_chat_screen.dart';

Future showContactSearchBar(BuildContext context, WidgetRef ref) async {
  List<ChatContact> contacts = await ref.read(chatControllerProvider).getSearchedContacts();
  return showSearch(
    context: context,
    delegate: SearchPage(
      items: contacts,
      searchLabel: 'Search...',
      suggestion: const ContactsList(),
      builder: (contact) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, MobileChatScreen.routeName, arguments: {
              'name': contact.name,
              'uid': contact.contactId,
              'isGroupChat': contact.isGroupChat,
              'numberOfMembers': contact.numberOfMembers,
              'profilePic': contact.profilePic,
            });
          },
          child: ListTile(
            title: Text(
              contact.name,
              style: const TextStyle(fontSize: 18),
            ),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(contact.profilePic),
              radius: 30,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                contact.lastMessage,
                style: const TextStyle(fontSize: 14, color: Colors.white54),
              ),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(),
                Text(
                  contact.timeSent.isAfter(DateTime.now().subtract(const Duration(hours: 24)))
                      ? DateFormat.jm().format(contact.timeSent)
                      : DateFormat('d/MM/yy').format(contact.timeSent),
                  style: TextStyle(
                    color: contact.unSeenMessageCount == 0 ?  Colors.grey : unSeenMessageColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                contact.unSeenMessageCount != 0 ? Container(
                  width: 25,
                  height: 25,
                  decoration: const BoxDecoration(
                    color: unSeenMessageColor,
                    shape: BoxShape.circle,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(contact.unSeenMessageCount.toString(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                  ),
                ) : const SizedBox(),
              ],
            ),
          ),
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
