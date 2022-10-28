import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/common/utils/colors.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/features/call/controller/call_controller.dart';

import '../../../common/widgets/loader.dart';
import '../../../model/call.dart';

class CallLogs extends ConsumerWidget {
  const CallLogs({Key? key}) : super(key: key);

  void makeCall(WidgetRef ref, BuildContext context, Call callData){
    ref.read(callControllerProvider).makeCall(context, callData.receiverName, callData.receiverId, callData.receiverPic, callData.isGroupCall, callData.isVideoCall);
  }

    @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const ScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16,12,0,12),
            child: Text('Recent', style: TextStyle(fontSize: 15, color: Colors.white54),),
          ),
          FutureBuilder<List<Call>>(
              future: ref.watch(callControllerProvider).getCallLogs(),
              builder: (context, snapshot){
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }
                String uid = ref.read(authControllerProvider).uid();
                return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var callData = snapshot.data![index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          title: Text(
                            callData.callerId == uid || callData.isGroupCall
                                ? callData.receiverName
                                : callData.callerName,
                            style: const TextStyle(fontSize: 18),
                          ),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              callData.callerId == uid || callData.isGroupCall
                                  ? callData.receiverPic
                                  : callData.callerPic,
                            ),
                            radius: 30,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top : 6.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  callData.callerId == uid
                                      ? Icons.call_made
                                      : Icons.call_received,
                                  color: callData.isMissedCall
                                      ? Colors.red
                                      : Colors.green,
                                ),
                                const SizedBox(width: 5,),
                                Text(DateFormat.yMd().add_jm().format(callData.callTime)),
                              ],
                            ),
                          ),
                          trailing: Padding(
                            padding: const EdgeInsets.fromLTRB(0,0,4,8),
                            child: IconButton(
                              icon: Icon(
                                callData.isVideoCall
                                    ? Icons.video_call
                                    : Icons.call,
                                color: unSeenMessageColor,
                                size: callData.isVideoCall ? 40 : 30,
                              ),
                              onPressed: () => makeCall(ref, context, callData),
                            ),
                          ),
                        ),
                      );
                    }
                );
              }
          ),
        ],
      ),
    );
  }
}
