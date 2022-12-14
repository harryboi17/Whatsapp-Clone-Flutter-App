import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/common/utils/responsive_layout.dart';
import 'package:whatsapp_clone/common/widgets/error.dart';
import 'package:whatsapp_clone/common/widgets/loader.dart';
import 'package:whatsapp_clone/features/landing/screens/landing_screen.dart';
import 'package:whatsapp_clone/features/notification/repository/notification_repository.dart';
import 'package:whatsapp_clone/firebase_options.dart';
import 'package:whatsapp_clone/router.dart';
import 'package:whatsapp_clone/screens/mobile_layout_screen.dart';
import 'package:whatsapp_clone/screens/web_layout_screen.dart';
import 'common/utils/colors.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationRepository.initialize();
  FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessaging);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Whatsapp Clone',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          color: appBarColor,
        )
      ),
      onGenerateRoute: (settings) => generateRoute(settings),
      // home: const ResponsiveLayout(
      //     mobileScreenLayout: MobileLayoutScreen(),
      //     webScreenLayout: WebLayoutScreen(),
      // ),
      home: ref.watch(userDataAuthProvider).when(
        data: (user){
          if(user == null) {
            return const LandingScreen();
          } else {
            return const ResponsiveLayout(mobileScreenLayout: MobileLayoutScreen(), webScreenLayout: WebLayoutScreen());
          }
        },
        error: (err, trace){
          return ErrorScreen(error: err.toString());
        },
        loading: () => const Loader(),
      ),
    );
  }
}

Future<void> _handleBackgroundMessaging(RemoteMessage message) async {
  if(kDebugMode)print("Background message received");
}
