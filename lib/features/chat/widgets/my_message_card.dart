import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:whatsapp_clone/features/chat/widgets/display_text_file.dart';
import '../../../common/enums/message_enum.dart';
import '../../../common/utils/colors.dart';

class MyMessageCard extends StatelessWidget {
  final String message;
  final String date;
  final MessageEnum type;
  final VoidCallback onSwipe;
  final bool isSeen;
  final String repliedText;
  final String userName;
  final MessageEnum repliedMessageType;

  const MyMessageCard(
      {Key? key, required this.message, required this.date, required this.type, required this.isSeen,
        required this.onSwipe, required this.repliedMessageType, required this.repliedText, required this.userName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isReplying = repliedText.isNotEmpty;

    return SwipeTo(
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
                                        userName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: micColor
                                        ),
                                      ),
                                      const SizedBox(height: 4,),
                                      repliedMessageType == MessageEnum.text
                                          ? DisplayTextFile(
                                            message: repliedText.length > 70  ? "${repliedText.substring(0,70)}..." : repliedText,
                                            type: repliedMessageType,
                                            color: Colors.grey,
                                            size: MediaQuery.of(context).size.height/64,
                                          )
                                          : DisplayTextFile(
                                              message: displayMessageForMessageType(repliedMessageType),
                                              type: MessageEnum.text,
                                              color: Colors.grey,
                                              size: 14,
                                          ),
                                    ],
                                  ),
                                ),
                                if(repliedMessageType != MessageEnum.text && repliedMessageType != MessageEnum.audio)...[
                                    const SizedBox(width: 15),
                                    Container(
                                      color: Colors.transparent,
                                      width: MediaQuery.of(context).size.width/8,
                                      height: 50,
                                      child: DisplayTextFile(message: repliedText, type: repliedMessageType, size: 14, color: Colors.grey,),
                                    ),
                                ]
                              ],
                            ),
                          ),
                      ),
                    ) else const SizedBox(),
                    Padding(
                      padding: type == MessageEnum.text
                          ? const EdgeInsets.only(
                        left: 10,
                        right: 20,
                        top: 5,
                        bottom: 20,
                      )
                          : const EdgeInsets.only(
                        left: 5,
                        top: 5,
                        right: 5,
                        bottom: 20,
                      ),
                      child: DisplayTextFile(message: message, type: type, color: Colors.white, size: 16,),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 1,
                  right: 10,
                  child: Row(
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Icon(
                        isSeen ?  Icons.done_all : Icons.done,
                        size: 16,
                        color: isSeen ? Colors.blue :  Colors.white60,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
