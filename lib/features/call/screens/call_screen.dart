import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/config/agora_config.dart';
import '../../../model/call.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String channelId;
  final Call call;
  final bool isGroupChat;

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

  @override
  void initState() {
    super.initState();
    client = AgoraClient(agoraConnectionData: AgoraConnectionData(appId: AgoraConfig.appId, channelName: widget.channelId, tokenUrl: ));
  }
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
