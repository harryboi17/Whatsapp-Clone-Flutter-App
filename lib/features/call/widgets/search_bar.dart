import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:search_page/search_page.dart';
import 'package:whatsapp_clone/features/call/controller/call_controller.dart';
import 'package:whatsapp_clone/features/call/screens/call_log_screen.dart';
import '../../../common/utils/colors.dart';
import '../../../model/call.dart';
import '../../auth/controller/auth_controller.dart';

void makeCall(WidgetRef ref, BuildContext context, Call callData){
  ref.read(callControllerProvider).makeCall(context, callData.receiverName, callData.receiverId, callData.receiverPic, callData.isGroupCall, callData.isVideoCall);
}

Future showCallSearchBar(BuildContext context, WidgetRef ref) async {
  List<Call> callLogs = await ref.read(callControllerProvider).getCallLogs();
  String uid = ref.read(authControllerProvider).uid();
  return showSearch(
    context: context,
    delegate: SearchPage(
      items: callLogs,
      searchLabel: 'Search...',
      suggestion: const CallLogs(),
      builder: (callData) => Padding(
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
      ),
      filter: (callData) => [
        callData.callerId == uid || callData.isGroupCall
            ? callData.receiverName
            : callData.callerName,
        callData.callerId == uid || callData.isGroupCall
            ? callData.receiverPhoneNumber
            : callData.callerPhoneNumber,
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
