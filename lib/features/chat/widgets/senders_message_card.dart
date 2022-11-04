import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:whatsapp_clone/features/chat/widgets/display_text_file.dart';
import '../../../common/enums/message_enum.dart';
import '../../../common/utils/colors.dart';
import '../../../model/message.dart';
import 'app_bar.dart';

class SenderMessageCard extends ConsumerStatefulWidget {
  const SenderMessageCard({Key? key, required this.onSwipe, required this.onLongPressed, required this.onPressed, required this.messageData,
    required this.isGroupChat, required this.onRepliedMessagePressed})
      : super(key: key);
  final VoidCallback onSwipe;
  final VoidCallback onPressed;
  final VoidCallback onLongPressed;
  final VoidCallback onRepliedMessagePressed;
  final Message messageData;
  final bool isGroupChat;

  @override
  ConsumerState<SenderMessageCard> createState() => _SenderMessageCardState();
}

class _SenderMessageCardState extends ConsumerState<SenderMessageCard> with TickerProviderStateMixin {
  late final AnimationController animationController;
  late Animation<double> animation1;
  late Animation<double> animation2;
  @override
  void initState() {
    // TODO: implement initState
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    animation1 = Tween<double>(begin: 1.0, end: 1.5).animate(animationController);
    animation2 = Tween<double>(begin: 1, end: 0.2).animate(animationController);
    super.initState();
  }
  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReplying = widget.messageData.repliedMessage.isNotEmpty;
    var timeSent = DateFormat.jm().format(widget.messageData.timeSent);

    if(ref.watch(animationProvider) == widget.messageData.messageId){
      animationController.forward().whenComplete(() => animationController.reset());
      ref.invalidate(animationProvider);
    }

    return Container(
      color: ref.watch(appBarMessageProvider).contains(widget.messageData) ? messageColor.withOpacity(0.5) : Colors.transparent,
      child: InkWell(
        onLongPress: widget.onLongPressed,
        onTap: widget.onPressed,
        child: SwipeTo(
          onRightSwipe: widget.onSwipe,
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width / 1.25,
                minWidth: MediaQuery.of(context).size.width / 3.5,
              ),
              child: AnimatedBuilder(
                animation: animationController.view,
                builder: (BuildContext context, Widget? child) {
                  return FadeTransition(opacity: animation2, child: child,);
                },
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
                          if (isReplying) InkWell(
                            onTap: widget.onRepliedMessagePressed,
                            child: Padding(
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
                                              widget.messageData.repliedTo,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: micColor
                                              ),
                                            ),
                                            const SizedBox(height: 4,),
                                            widget.messageData.repliedMessageType == MessageEnum.text
                                                ? Text(
                                                  widget.messageData.repliedMessage,
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: MediaQuery.of(context).size.height/64,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                )
                                                : DisplayTextFile(
                                                  message: displayMessageForMessageType(widget.messageData.repliedMessageType),
                                                  type: MessageEnum.text,
                                                  color: Colors.grey,
                                                  size: 14,
                                                ),
                                          ],
                                        ),
                                      ),
                                      if(widget.messageData.repliedMessageType != MessageEnum.text && widget.messageData.repliedMessageType != MessageEnum.audio)...[
                                        const SizedBox(width: 15),
                                        Container(
                                          color: Colors.transparent,
                                          width: MediaQuery.of(context).size.width/8,
                                          height: 50,
                                          child: DisplayTextFile(message: widget.messageData.repliedMessage, type: widget.messageData.repliedMessageType, size: 14, color: Colors.grey,),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ) else const SizedBox(),
                          Padding(
                            padding: widget.messageData.type == MessageEnum.text
                                ? const EdgeInsets.only(left: 10, right: 20, top: 5, bottom: 20,)
                                : const EdgeInsets.only(left: 5, top: 5, right: 5, bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                widget.isGroupChat
                                  ? Text(widget.messageData.senderName, style: const TextStyle(color: micColor),)
                                  : const SizedBox(),
                                widget.messageData.isDeleted
                                    ? DisplayTextFile(message: widget.messageData.text, type: widget.messageData.type, color: Colors.grey, size: 16,)
                                    : DisplayTextFile(message: widget.messageData.text, type: widget.messageData.type, color: Colors.white, size: 16,),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 2,
                        right: 10,
                        child: Text(
                          timeSent,
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
          ),
        ),
      ),
    );
  }
}
