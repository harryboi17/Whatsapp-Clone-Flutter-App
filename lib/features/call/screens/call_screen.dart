import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/config/agora_config.dart';
import 'package:whatsapp_clone/features/call/controller/call_controller.dart';
import '../../../common/widgets/loader.dart';
import '../../../model/call.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String channelId;
  final Call call;
  final bool isGroupChat;
  static const String routeName = 'call-screen';

  const CallScreen({
    Key? key,
    required this.channelId,
    required this.call,
    required this.isGroupChat,
  }) : super(key : key);

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  AgoraClient? client;
  String baseUrl =  'https://whatsapp-clone-harry.herokuapp.com';

  @override
  void initState() {
    super.initState();
    client = AgoraClient(agoraConnectionData: AgoraConnectionData(appId: AgoraConfig.appId, channelName: widget.channelId, tokenUrl: baseUrl));
    initAgora();
  }

  void initAgora() async{
    await client!.initialize();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: client == null
            ? const Loader()
            : SafeArea(
          child: Stack(
            children: [
              AgoraVideoViewer(client: client!),
              AgoraVideoButtons(
                client: client!,
                disconnectButtonChild: IconButton(
                  onPressed: ()async{
                    await client!.engine.leaveChannel();
                    ref.read(callControllerProvider).endCall(callerId: widget.call.callerId, receiverId: widget.call.receiverId, context: context, isGroupChat: widget.isGroupChat);
                  },
                  icon: const Icon(Icons.call_end),
                ),
              ),
            ],
          ),
        )
    );
  }
}
