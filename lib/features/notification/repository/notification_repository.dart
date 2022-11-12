import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../auth/controller/auth_controller.dart';

final notificationRepositoryProvider = Provider(
        (ref) => NotificationRepository(FirebaseMessaging.instance, ref));

class NotificationRepository {
  final FirebaseMessaging firebaseMessaging;
  final ProviderRef ref;
  NotificationRepository(this.firebaseMessaging, this.ref);

  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize() {
    const InitializationSettings initializationSettings =
    InitializationSettings(android: AndroidInitializationSettings("@mipmap/ic_launcher"));
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void storeNotificationToken()async{
    String? token = await firebaseMessaging.getToken();
    ref.read(authControllerProvider).updateUserToken(token);
  }

  void initializeCloudMessaging(BuildContext context){
    firebaseMessaging.getInitialMessage();
    FirebaseMessaging.onMessage.listen((message) {
      display(message, context);
    });
  }

  static void sendNotification({
    required String? title,
    required String? message,
    required String? token,
    required String collapseKey,
  })async{
    const String serverKey = 'AAAA54QZUU4:APA91bFVaDDLMbRyKXwfYzihXmLodbs8uQqInO0ovKYAJi7CydChvueGHMEvBTSm0md5Ybdn2jdIHFQiExr-F3zhdahs259Cbte1dc7SwhrJHNtu1OHZyq4u5nEnO4gdxA-C9tKYKE1P';
    final data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'message': message,
      "collapse_key": collapseKey,
    };

    try{
      http.Response response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String,String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=$serverKey'
          },
          body: jsonEncode(<String,dynamic>{
            'notification': <String,dynamic> {
              'title': title,
              'body': message,
            },
            'priority': 'high',
            'data': data,
            'to': token,
          })
      );

      if(response.statusCode == 200){
        if(kDebugMode)print("Yeh notificatin is sended");
      }else{
        if(kDebugMode)print("Error");
      }
    }catch(e){
      if(kDebugMode)print(e);
    }
  }


  static void display(RemoteMessage message, BuildContext context) async{
    try {
      String displayMessage = message.notification!.body!;
      const String groupKey = 'group-key';
      // Random random = Random();
      // int id = random.nextInt(1000);
      int mod = 1000007;
      int id = 0;
      for(int i = 0; i < message.collapseKey!.length; i++){
        id = ((10*id) + message.collapseKey!.codeUnitAt(i) + 1)%mod;
      }

      final List<ActiveNotification>? activeNotifications = await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.getActiveNotifications();
      if(activeNotifications != null){
        for(var notification in activeNotifications){
          if(notification.id == id){
            displayMessage = '${notification.body!}\n$displayMessage';
          }
        }
      }

      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "myChannel",
          "my channel",
          importance: Importance.max,
          priority: Priority.high,
          groupKey: groupKey,
          setAsGroupSummary: true,
          styleInformation: BigTextStyleInformation(''),
        ),
      );
      await _flutterLocalNotificationsPlugin.show(
        id,
        message.notification!.title,
        displayMessage,
        notificationDetails,
      );
    } on Exception catch (e) {
      // showSnackBar(context: context, content: e.toString());
      if(kDebugMode )print('Error>>>$e');
    }
  }
}