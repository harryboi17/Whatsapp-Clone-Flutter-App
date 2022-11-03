import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';
import 'package:whatsapp_clone/common/utils/colors.dart';
import 'package:whatsapp_clone/features/chat/widgets/display_text_file.dart';
import '../../../common/provider/message_reply_provider.dart';

class MessageReplyPreview extends ConsumerWidget {
  const MessageReplyPreview({Key? key}) : super(key: key);

  void cancelReply(WidgetRef ref) {
    ref.read(messageReplyProvider.notifier).update((state) => null);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageReply = ref.watch(messageReplyProvider);

    return Container(
      margin: const EdgeInsets.only(left: 5),
      width: MediaQuery.of(context).size.width/1.175,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: const BoxDecoration(
        color: mobileChatBoxColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8,3,3,5),
        decoration: const BoxDecoration(
          color: Colors.black12,
          border: Border(left: BorderSide(color: micColor, width: 3.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    messageReply!.isMe ? 'You' : messageReply.repliedTo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: micColor
                    ),
                  ),
                  const SizedBox(height: 8),
                  messageReply.messageEnum == MessageEnum.text
                      ? Text(
                          messageReply.message,
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                      )
                      : Text(
                          displayMessageForMessageType(messageReply.messageEnum),
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.topRight,
              children: [
                messageReply.messageEnum != MessageEnum.text && messageReply.messageEnum != MessageEnum.audio
                    ? Container(
                      color: Colors.transparent,
                      width: MediaQuery.of(context).size.width/7,
                      height: 50,
                      child: DisplayTextFile(message: messageReply.message, type: messageReply.messageEnum, size: 14, color: Colors.grey,),
                    )
                    : Container(),
                GestureDetector(
                  child: const Icon(
                    Icons.close_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                  onTap: () => cancelReply(ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}