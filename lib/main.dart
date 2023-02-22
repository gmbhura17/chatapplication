import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chatapplication/Chatapp.dart';
import 'package:chatapplication/GoogleMapProject.dart';
import 'package:chatapplication/LocalNotification.dart';
import 'package:chatapplication/OnlinePaymentExample.dart';
import 'package:chatapplication/SplashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main()  async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  await FirebaseMessaging.instance.getToken().then((token) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", token!);
  });

  //
  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 123,
            channelKey: "basic_channel",
            title: notification!.title.toString(),
            body: notification.body.toString()
        )
    );
  }
  FirebaseMessaging.onMessage.listen(showFlutterNotification);
  //


  AwesomeNotifications().initialize(
      'resource://drawable/launch_background',
      [
        NotificationChannel(
            channelGroupKey: 'basic_tests',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white,
            importance: NotificationImportance.High,
            enableVibration: true,
        ),
        NotificationChannel(
            channelGroupKey: 'basic_tests',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for image tests',
            defaultColor: Colors.redAccent,
            ledColor: Colors.white,
            channelShowBadge: true,
            importance: NotificationImportance.High
        )
      ],
      channelGroups: [
        NotificationChannelGroup(channelGroupkey: 'basic_tests', channelGroupName: 'Basic tests'),
      ],
      debug: true
  );
  runApp( MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}
