import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:whatsapp_clone/features/chat/widgets/display_text_file.dart';
import '../../../common/enums/message_enum.dart';
import '../../../common/utils/colors.dart';

class SenderMessageCard extends StatelessWidget {
  const SenderMessageCard(
      {Key? key, required this.message, required this.date, required this.type,
      required this.onSwipe, required this.repliedMessageType, required this.repliedText, required this.userName})
      : super(key: key);
  final String message;
  final String date;
  final MessageEnum type;
  final VoidCallback onSwipe;
  final String repliedText;
  final String userName;
  final MessageEnum repliedMessageType;

  @override
  Widget build(BuildContext context) {
    final isReplying = repliedText.isNotEmpty;

    return SwipeTo(
      onRightSwipe: onSwipe,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width / 1.25,
            minWidth: MediaQuery.of(context).size.width / 3.5,
          ),
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: senderMessageColor,
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
                                      message: repliedText.length > 60  ? "${repliedText.substring(0,60)}..." : repliedText,
                                      type: repliedMessageType,
                                      color: Colors.grey,
                                      size: 14,
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
                                left: 5, top: 5, right: 5, bottom: 20),
                        child: DisplayTextFile(message: message, type: type, color: Colors.white, size: 16,)),
                  ],
                ),
                Positioned(
                  bottom: 2,
                  right: 10,
                  child: Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
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
