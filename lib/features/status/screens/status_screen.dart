import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/utils.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:whatsapp_clone/features/status/controller/status_controller.dart';
import '../../../common/widgets/loader.dart';
import '../../../model/status_model.dart';

class StatusScreen extends ConsumerStatefulWidget {
  static const String routeName = '/status-screen';
  final UserStatus status;
  const StatusScreen({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  ConsumerState<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends ConsumerState<StatusScreen> {
  StoryController controller = StoryController();
  List<StoryItem> storyItems = [];

  @override
  void initState() {
    super.initState();
    initStoryPageItems();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void initStoryPageItems() {
    for (int i = 0; i < widget.status.photoUrl.length; i++) {
      storyItems.add(StoryItem.pageImage(
        url: widget.status.photoUrl[i],
        controller: controller,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: storyItems.isEmpty
          ? const Loader()
          : StoryView(
        storyItems: storyItems,
        controller: controller,
        onVerticalSwipeComplete: (direction) {
          if (direction == Direction.down) {
            Navigator.pop(context);
          }
        },
        onComplete: () => Navigator.pop(context),
        onStoryShow: (storyItem){
          int index = storyItems.indexOf(storyItem);
          ref.read(statusControllerProvider).updateIsSeen(widget.status.uid, widget.status.statusId[index]);
        },
      ),
    );
  }
}