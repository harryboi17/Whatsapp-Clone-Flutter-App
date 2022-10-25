import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/auth/screens/login_screen.dart';
import 'package:whatsapp_clone/features/auth/screens/otp_screen.dart';
import 'package:whatsapp_clone/features/auth/screens/user_information.dart';
import 'package:whatsapp_clone/common/widgets/error.dart';
import 'package:whatsapp_clone/features/call/screens/call_screen.dart';
import 'package:whatsapp_clone/features/select_contacts/screens/select_contacts_screen.dart';
import 'package:whatsapp_clone/features/chat/screens/mobile_chat_screen.dart';
import 'package:whatsapp_clone/features/status/screens/confirm_status_screen.dart';
import 'package:whatsapp_clone/features/status/screens/status_screen.dart';
import 'package:whatsapp_clone/screens/mobile_layout_screen.dart';

import 'features/group/screens/create_group_screen.dart';
import 'model/status_model.dart';

Route<dynamic> generateRoute(RouteSettings settings){
  switch(settings.name){
    case LoginScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
      );
    case OTPScreen.routeName:
      final verificationId = settings.arguments as String;
      return MaterialPageRoute(
          builder: (context) => OTPScreen(verificationId: verificationId),
      );
    case UserInformationScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const UserInformationScreen(),
      );
    case MobileLayoutScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => const MobileLayoutScreen()
      );
    case SelectContactScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => SelectContactScreen()
      );
    case MobileChatScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final name = arguments['name'];
      final uid = arguments['uid'];
      final isGroupChat = arguments['isGroupChat'];
      final numberOfMembers = arguments['numberOfMembers'];
      final profilePic = arguments['profilePic'];
      return MaterialPageRoute(
          builder: (context) => MobileChatScreen(name: name, uid: uid, isGroupChat: isGroupChat, numberOfMembers: numberOfMembers, profilePic: profilePic,)
      );
    case ConfirmStatusScreen.routeName:
      final file = settings.arguments as File;
      return MaterialPageRoute(
          builder: (context) => ConfirmStatusScreen(file: file)
      );
    case StatusScreen.routeName:
      final status = settings.arguments as UserStatus;
      return MaterialPageRoute(
          builder: (context) => StatusScreen(status: status)
      );
    case CreateGroupScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => const CreateGroupScreen()
      );
    case CallScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final channelId = arguments['channelId'];
      final call = arguments['call'];
      final isGroupChat = arguments['isGroupChat'];
      return MaterialPageRoute(
          builder: (context) => CallScreen(channelId: channelId, call: call, isGroupChat: isGroupChat)
      );
    default:
      return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: ErrorScreen(error: 'This page doesn\'t exists')
          ),
      );
  }
}