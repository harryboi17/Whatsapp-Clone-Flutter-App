import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:whatsapp_clone/features/chat/widgets/display_text_file.dart';
import '../../../common/enums/message_enum.dart';
import '../../../common/utils/colors.dart';
import '../../../model/message.dart';
import 'app_bar.dart';

class MyMessageCard extends ConsumerStatefulWidget {
  final VoidCallback onSwipe;
  final VoidCallback onPressed;
  final VoidCallback onLongPressed;
  final VoidCallback onRepliedMessagePressed;
  final bool isSeen;
  final Message messageData;

  const MyMessageCard({Key? key, required this.isSeen, required this.onSwipe, required this.onLongPressed, required this.onPressed,
    required this.messageData, required this.onRepliedMessagePressed})
      : super(key: key);

  @override
  ConsumerState<MyMessageCard> createState() => _MyMessageCardState();
}

class _MyMessageCardState extends ConsumerState<MyMessageCard> with SingleTickerProviderStateMixin{
  late final AnimationController animationController;
  late Animation<Color?> animationColor;

  @override
  void initState() {
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    animationColor = Tween<Color?>(begin: messageColor.withOpacity(0.5), end: Colors.transparent).animate(animationController);
    super.initState();
  }
  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var color = ref.watch(appBarMessageProvider).contains(widget.messageData) ? messageColor.withOpacity(0.5) : Colors.transparent;
    final isReplying = widget.messageData.repliedMessage.isNotEmpty;
    var timeSent = DateFormat.jm().format(widget.messageData.timeSent);

    if(ref.watch(animationProvider) == widget.messageData.messageId){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        animationController.forward().whenComplete((){
          animationController.reverse();
          setState(() {});
        });
        ref.invalidate(animationProvider);
      });
    }

    return Container(
      color: animationController.isAnimating ? animationColor.value ?? Colors.transparent : color,
      child: InkWell(
        onLongPress:widget.onLongPressed,
        onTap:widget.onPressed,
        child: SwipeTo(
          onRightSwipe: widget.onSwipe,
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
                              : const EdgeInsets.only(left: 5, top: 5, right: 5, bottom: 20,),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              widget.messageData.isForwarded
                                  ? SizedBox(
                                    width: 100,
                                    height: 30,
                                    child: Row(
                                      children: const[
                                        Icon(Icons.forward, color: Colors.grey,),
                                        Text('Forwarded', style: TextStyle(color: Colors.grey, fontSize: 14),),
                                      ],
                                    ),
                                  )
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
                          !widget.messageData.isDeleted
                              ? Icon(
                                widget.isSeen ?  Icons.done_all : Icons.done,
                                size: 16,
                                color: widget.isSeen ? Colors.blue :  Colors.white60,
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
