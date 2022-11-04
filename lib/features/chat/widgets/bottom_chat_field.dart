import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_clone/common/provider/message_reply_provider.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_clone/features/chat/widgets/emoji_keyboard.dart';
import 'package:whatsapp_clone/features/chat/widgets/message_reply_preview.dart';
import '../../../common/enums/message_enum.dart';
import '../../../common/utils/colors.dart';

class BottomChatField extends ConsumerStatefulWidget {
  final String receiverUserId;
  final String receiverName;
  final bool isGroupChat;
  const BottomChatField({Key? key, required this.receiverUserId, required this.receiverName, required this.isGroupChat}) : super(key: key);

  @override
  ConsumerState<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends ConsumerState<BottomChatField> with TickerProviderStateMixin{
  bool isShowSendButton = false;
  final TextEditingController _messageController = TextEditingController();
  FlutterSoundRecorder? _soundRecorder;
  bool isShowEmojiContainer = false;
  bool isRecorderInit = false;
  bool isRecording = false;
  FocusNode focusNode = FocusNode();
  late Timer typingTimer;


  @override
  void initState() {
    super.initState();
    _soundRecorder = FlutterSoundRecorder();
    typingTimer = Timer(const Duration(milliseconds: 1), () { });
  }

  void openAudio() async{
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        showSnackBar(
            context: context, content: "MicroPhone permission not allowed");
        return;
      }
  }

  void sendTextMessage() async{
    if(isShowSendButton){
      ref.read(chatControllerProvider).sendTextMessage(context, _messageController.text.trim(), widget.receiverUserId, widget.isGroupChat);
      setState(() {
        _messageController.text = '';
      });
    }
    else{
      if(await Permission.microphone.isGranted){
        var tempDirectory = await getTemporaryDirectory();
        var path = '${tempDirectory.path}/flutter_sound.aac';

        if(!isRecorderInit){
          await _soundRecorder!.openRecorder();
          isRecorderInit = true;
        }

        if(isRecording){
          await _soundRecorder!.stopRecorder();
          sendFileMessage(File(path), MessageEnum.audio);
        }else{
          await _soundRecorder!.startRecorder(
            toFile: path,
          );
        }
        setState(() => isRecording = !isRecording );
      }else{
        openAudio();
      }
    }
  }
  
  void addEmojiToTextField(String emoji){
    setState(() {
      _messageController.text += emoji;
      if(_messageController.text.isNotEmpty){isShowSendButton = true;}
    });
  }

  void sendFileMessage(File file, MessageEnum messageEnum){
    ref.read(chatControllerProvider).sendFileMessage(context, file, widget.receiverUserId, messageEnum, widget.isGroupChat);
  }

  void selectImage() async{
    File? image = await pickImageFromGallery(context);
    if(image != null){
      sendFileMessage(image, MessageEnum.image);
    }
  }

  void selectVideo() async{
    File? video = await pickVideoFromGallery(context);
    if(video != null){
      sendFileMessage(video, MessageEnum.video);
    }
  }

  void showKeyBoard() => focusNode.requestFocus();
  void hideKeyBoard() => focusNode.unfocus();

  void hideEmojiContainer(){
    setState(() {
      isShowEmojiContainer = false;
    });
  }
  void showEmojiContainer(){
    setState(() {
      isShowEmojiContainer = true;
    });
  }

  void toggleEmojiKeyboardContainer(){
    if(isShowEmojiContainer){
      showKeyBoard();
      hideEmojiContainer();
    }
    else{
      hideKeyBoard();
      showEmojiContainer();
    }
  }

  void startTypingAnimation(WidgetRef ref){
    typingTimer = Timer( const Duration(seconds: 1),
            () => ref.read(authControllerProvider).setUserTypingStatus(false, widget.receiverUserId, widget.isGroupChat));
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    _soundRecorder!.closeRecorder();
    typingTimer.cancel();
    isRecorderInit = false;
  }

  @override
  Widget build(BuildContext context) {
    final messageReply = ref.watch(messageReplyProvider);
    final isShowMessageReply = messageReply != null;


    return WillPopScope(
      onWillPop: () async{
        if(isShowEmojiContainer){
          hideEmojiContainer();
        }
        else{
          Navigator.pop(context);
        }
        return false;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isShowMessageReply
              ? const MessageReplyPreview()
              : const SizedBox(),
          Padding(
            padding: const EdgeInsets.fromLTRB(5,4,3,6),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    onTap: hideEmojiContainer,
                    focusNode: focusNode,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    maxLines: null,
                    controller: _messageController,
                    onChanged: (value){
                        setState((){
                          if(value.isNotEmpty) {isShowSendButton = true;}
                          else{isShowSendButton = false;}
                        });
                        if(value.isNotEmpty) {
                          ref.read(authControllerProvider).setUserTypingStatus(true, widget.receiverUserId, widget.isGroupChat);
                          if(typingTimer.isActive){
                            typingTimer.cancel();
                          }
                          startTypingAnimation(ref);
                        }
                        else{
                          ref.read(authControllerProvider).setUserTypingStatus(false, widget.receiverUserId, widget.isGroupChat);
                        }
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: mobileChatBoxColor,
                      prefixIcon: IconButton(
                        onPressed: toggleEmojiKeyboardContainer,
                        icon: const Icon(Icons.emoji_emotions, color: Colors.grey,),
                      ),
                      suffixIcon: SizedBox(
                        width: 98,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              onPressed: selectImage,
                              icon: const Icon(Icons.camera_alt, color: Colors.grey, size: 22,),
                            ),
                            IconButton(
                              onPressed: selectVideo,
                              icon: const Icon(Icons.attach_file, color: Colors.grey, size: 22,),
                            ),
                          ],
                        ),
                      ),
                      hintText: 'Type a message!',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 2.0),
                  child: CircleAvatar(
                    backgroundColor: micColor,
                    radius: 24,
                    child: GestureDetector(
                      onTap: sendTextMessage,
                      child: Icon(
                        isShowSendButton
                            ? Icons.send
                            : isRecording
                                ? Icons.close
                                : Icons.mic,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          isShowEmojiContainer
              ?  CustomEmojiKeyboard(
                  addEmojiToTextField: addEmojiToTextField,
                  receiverUserId: widget.receiverUserId,
                  popGifScreen: hideEmojiContainer,
                  isGroupChat: widget.isGroupChat,
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
