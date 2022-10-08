import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/features/chat/controller/chat_controller.dart';

import '../../../common/utils/colors.dart';
class CustomEmojiKeyboard extends ConsumerStatefulWidget {
  final Function addEmojiToTextField;
  final String receiverUserId;
  final Function popGifScreen;
  final bool isGroupChat;
  const CustomEmojiKeyboard({Key? key, required this.addEmojiToTextField, required this.receiverUserId, required this.popGifScreen, required this.isGroupChat}) : super(key: key);

  @override
  ConsumerState<CustomEmojiKeyboard> createState() => _CustomEmojiKeyboardState();
}

class _CustomEmojiKeyboardState extends ConsumerState<CustomEmojiKeyboard> with TickerProviderStateMixin {
  int currentIndex = 0;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  void selectGif() async{
    final gif = await pickGIF(context);
    if(gif != null){
      ref.read(chatControllerProvider).sendGIFMessage(context, gif.url, widget.receiverUserId, widget.isGroupChat);
    }
    widget.popGifScreen();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height/3.1,
      child: Scaffold(
        bottomNavigationBar: SizedBox(
          height: kBottomNavigationBarHeight-13,
          child: BottomAppBar(
            color: mobileChatBoxColor,
            child: TabBar(
              indicatorColor: mobileChatBoxColor,
              labelColor: micColor,
              unselectedLabelColor: Colors.grey,
              controller: tabController,
              onTap: (index) {
                if (index == 1) selectGif();
                setState(() => currentIndex = index);
              },
              tabs: const [
                Tab(icon: Icon(Icons.emoji_emotions_outlined),),
                Tab(icon: Icon(Icons.gif, size: 40,),),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children:[
            EmojiPicker(
              onEmojiSelected: (category, emoji) => widget.addEmojiToTextField(emoji.emoji),
              config: const Config(
                bgColor: backgroundColor,
                columns: 8,
              ),
            ),
            Container(),
          ],
        ),
      ),
    );
  }
}
