import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:whatsapp_clone/features/chat/widgets/display_text_file.dart';
import '../../../common/enums/message_enum.dart';
import '../../../common/utils/colors.dart';
import '../../../model/message.dart';
import 'app_bar.dart';

class MyMessageCard extends ConsumerWidget {
  final VoidCallback onSwipe;
  final VoidCallback onPressed;
  final VoidCallback onLongPressed;
  final bool isSeen;
  final Message messageData;

  const MyMessageCard({Key? key, required this.isSeen, required this.onSwipe, required this.onLongPressed, required this.onPressed, required this.messageData})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReplying = messageData.repliedMessage.isNotEmpty;
    var timeSent = DateFormat.jm().format(messageData.timeSent);

    return Container(
      color: ref.watch(appBarMessageProvider).contains(messageData) ? messageColor.withOpacity(0.5) : Colors.transparent,
      child: InkWell(
        onLongPress:onLongPressed,
        onTap:onPressed,
        child: SwipeTo(
          onRightSwipe: onSwipe,
          child: Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 1.25,
                  minWidth: MediaQuery.of(context).size.width / 3.5),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                color: messageColor,
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isReplying) Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height/13.5
                            ),
                            child: Container(
                                padding: const EdgeInsets.fromLTRB(8, 3, 3, 8),
                                decoration: const BoxDecoration(
                                  color: Colors.black12,
                                  border: Border(
                                      left: BorderSide(color: micColor, width: 3.5)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            messageData.repliedTo,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: micColor
                                            ),
                                          ),
                                          const SizedBox(height: 4,),
                                          messageData.repliedMessageType == MessageEnum.text
                                              ? Text(
                                                messageData.repliedMessage,
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: MediaQuery.of(context).size.height/64,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                              : DisplayTextFile(
                                                  message: displayMessageForMessageType(messageData.repliedMessageType),
                                                  type: MessageEnum.text,
                                                  color: Colors.grey,
                                                  size: 14,
                                              ),
                                        ],
                                      ),
                                    ),
                                    if(messageData.repliedMessageType != MessageEnum.text && messageData.repliedMessageType != MessageEnum.audio)...[
                                        const SizedBox(width: 15),
                                        Container(
                                          color: Colors.transparent,
                                          width: MediaQuery.of(context).size.width/8,
                                          height: 50,
                                          child: DisplayTextFile(message: messageData.repliedMessage, type: messageData.repliedMessageType, size: 14, color: Colors.grey,),
                                        ),
                                    ]
                                  ],
                                ),
                              ),
                          ),
                        ) else const SizedBox(),
                        Padding(
                          padding: messageData.type == MessageEnum.text
                              ? const EdgeInsets.only(left: 10, right: 20, top: 5, bottom: 20,)
                              : const EdgeInsets.only(left: 5, top: 5, right: 5, bottom: 20,),
                          child: messageData.isDeleted
                              ? DisplayTextFile(message: messageData.text, type: messageData.type, color: Colors.grey, size: 16,)
                              : DisplayTextFile(message: messageData.text, type: messageData.type, color: Colors.white, size: 16,),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 1,
                      right: 10,
                      child: Row(
                        children: [
                          Text(
                            timeSent,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          !messageData.isDeleted
                              ? Icon(
                                isSeen ?  Icons.done_all : Icons.done,
                                size: 16,
                                color: isSeen ? Colors.blue :  Colors.white60,
                              )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
