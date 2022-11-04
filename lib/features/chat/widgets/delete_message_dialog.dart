import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/utils/colors.dart';

import '../../../model/message.dart';
import '../controller/chat_controller.dart';
import 'app_bar.dart';
class DeleteMessageDialog extends ConsumerWidget {
  final bool isGroupChat;
  const DeleteMessageDialog({Key? key, required this.isGroupChat}) : super(key: key);

  void reset(WidgetRef ref, BuildContext context){
    ref.invalidate(appBarMessageProvider);
    ref.invalidate(chatScreenAppBarProvider);
    ref.invalidate(isLastMessageSelectedProvider);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18,18,18,10),
        color: appBarColor,
        height: 220,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Text('Delete message?', style: TextStyle(color: Colors.white54, fontSize: 15),),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 25,),
                buildTextButton('DELETE FOR EVERYONE', (){
                  List<Message> messages =  ref.read(appBarMessageProvider);
                  bool isLastMessageSelected = ref.read(isLastMessageSelectedProvider);
                  ref.read(chatControllerProvider).deleteMessageForEveryone(messages, isGroupChat, isLastMessageSelected);
                  reset(ref, context);
                }),
                buildTextButton('DELETE FOR ME', (){
                  List<Message> messages =  ref.read(appBarMessageProvider);
                  ref.read(chatControllerProvider).deleteMessageForMe(messages, isGroupChat);
                  reset(ref, context);
                }),
                buildTextButton('CANCEL', () => Navigator.pop(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextButton buildTextButton(String text, Function()? onPressed) {
    return TextButton(
      style: const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll<Color>(appBarColor)
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(color: unSeenMessageColor),),
    );
  }
}
