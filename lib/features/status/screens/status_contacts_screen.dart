import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/status/screens/status_screen.dart';
import '../../../common/utils/colors.dart';
import '../../../common/widgets/loader.dart';
import '../../../model/status_model.dart';
import '../controller/status_controller.dart';

class StatusContactsScreen extends ConsumerWidget{
  const StatusContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top : 8.0),
      child: FutureBuilder<List<UserStatus>>(
        future: ref.read(statusControllerProvider).getStatus(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var statusData = snapshot.data![index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, StatusScreen.routeName, arguments: statusData,);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        title: Text(
                          statusData.name,
                        ),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            statusData.profilePic,
                          ),
                          radius: 30,
                        ),
                      ),
                    ),
                  ),
                  const Divider(color: dividerColor, indent: 85),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
