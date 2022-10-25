import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:search_page/search_page.dart';
import 'package:whatsapp_clone/features/status/controller/status_controller.dart';
import 'package:whatsapp_clone/features/status/screens/status_contacts_screen.dart';
import 'package:whatsapp_clone/model/status_model.dart';
import '../../../common/widgets/circular_border.dart';
import '../screens/status_screen.dart';

Future showStatusSearchBar(BuildContext context, WidgetRef ref) async {
  List<UserStatus> statuses = await ref.read(statusControllerProvider).getSearchedStatus();
  return showSearch(
    context: context,
    delegate: SearchPage(
      items: statuses,
      searchLabel: 'Search...',
      suggestion: const StatusContactsScreen(),
      builder: (status) => InkWell(
        onTap: () {
          Navigator.pushNamed(context, StatusScreen.routeName, arguments: status,);
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            title: Text(
              status.name,
              style: const TextStyle(fontSize: 18),
            ),
            leading: Stack(
                children:[
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      status.profilePic
                    ),
                    radius: 30,
                  ),
                  CircularBorder(isSeenStatusList: status.isSeenStatus,),
                ]
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top : 6.0),
              child: Text(DateFormat.jm().format(status.lastUploadedStatusTime))
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
