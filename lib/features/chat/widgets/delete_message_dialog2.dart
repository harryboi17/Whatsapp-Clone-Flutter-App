import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/utils/colors.dart';
import '../../../model/message.dart';
import '../controller/chat_controller.dart';
import 'app_bar.dart';

class DeleteMessageDialog2 extends ConsumerWidget {
  final bool isGroupChat;
  const DeleteMessageDialog2({Key? key, required this.isGroupChat}) : super(key: key);

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
        height: 110,
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
            const SizedBox(height: 12,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
