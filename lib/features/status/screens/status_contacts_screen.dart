import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/common/widgets/circular_border.dart';
import 'package:whatsapp_clone/features/status/screens/status_screen.dart';
import '../../../common/utils/colors.dart';
import '../../../common/utils/utils.dart';
import '../../../common/widgets/loader.dart';
import '../../../model/status_model.dart';
import '../controller/status_controller.dart';
import 'confirm_status_screen.dart';

class StatusContactsScreen extends ConsumerWidget{
  const StatusContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top : 8.0),
          child: StreamBuilder<UserStatus>(
            stream: ref.read(statusControllerProvider).getMyStatus(context),
              builder: (context, snapshot){
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }
                return InkWell(
                  onTap: () async {
                    if(snapshot.data!.statusId.isEmpty){
                      File? pickedImage = await pickImageFromGallery(context);
                      if(pickedImage != null){
                        Navigator.pushNamed(context, ConfirmStatusScreen.routeName, arguments: pickedImage);
                      }
                    }else {
                      Navigator.pushNamed(context, StatusScreen.routeName, arguments: snapshot.data!,);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(
                        snapshot.data!.name,
                        style: const TextStyle(fontSize: 18),
                      ),
                      leading: Stack(
                        children:[
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              snapshot.data!.profilePic,
                            ),
                            radius: 30,
                          ),
                          CircularBorder(isSeenStatusList: snapshot.data!.isSeenStatus,),
                        ]
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top : 6.0),
                        child: snapshot.data!.statusId.isNotEmpty
                            ? Text(DateFormat.jm().format(snapshot.data!.lastUploadedStatusTime))
                            : const Text(
                              "Tap to add status update",
                              style: TextStyle(fontSize: 14, color: Colors.white54),
                            ),
                      ),
                    ),
                  ),
                );
              }
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16,8,0,0),
          child: Text('Recent updates', style: TextStyle(fontSize: 14, color: Colors.white54),),
        ),
        statusContactBuilder(ref, context, false),
        const Padding(
          padding: EdgeInsets.fromLTRB(16,8,0,0),
          child: Text('Viewed updates', style: TextStyle(fontSize: 14, color: Colors.white54),),
        ),
        statusContactBuilder(ref, context, true),
      ],
    );
  }

  Padding statusContactBuilder(WidgetRef ref, BuildContext context, bool isSeenStatusColumn) {
    return Padding(
    padding: const EdgeInsets.only(top : 8.0),
    child: StreamBuilder<List<UserStatus>>(
      stream: ref.read(statusControllerProvider).getStatus(context, isSeenStatusColumn),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }
        return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
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
                        style: const TextStyle(fontSize: 18),
                      ),
                      leading: Stack(
                        children:[
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              statusData.profilePic,
                            ),
                            radius: 30,
                          ),
                          CircularBorder(isSeenStatusList: statusData.isSeenStatus,),
                        ]
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top : 6.0),
                        child: Text(DateFormat.jm().format(statusData.lastUploadedStatusTime)),
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
