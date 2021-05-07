import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qrcode_receiver/model/push_message.dart';
import 'package:qrcode_receiver/pages/settings_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../encryption_utils.dart';
import '../local_notificaion.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription _localNotificationSubscription;

  @override
  void initState() {
    super.initState();

    _initMessaging();
    _initLocalNotification();
  }

  @override
  void dispose() {
    if (_localNotificationSubscription != null) {
      _localNotificationSubscription.cancel();
    }
    super.dispose();
  }

  void _urlLaunch(String content) async {
    String url = Uri.encodeFull('irma://qr/json/$content');

    launch(url).then((success) {
      if (!success) {
        final snackBar = SnackBar(content: Text('IRMA could not be opened. Is it installed?'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      print(success);
    });
  }

  void _initMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        PushMessage pushMessage = PushMessage.fromJson(message.data);
        RemoteNotification notification = message.notification;
        AndroidNotification android = message.notification?.android;

        // If `onMessage` is triggered with a notification, construct our own
        // local notification to show to users using the created channel.
        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channel.description,
                  icon: android?.smallIcon,
                  // other properties...
                ),
              ),
              payload: pushMessage.content);
        }
      });

      // Also handle any interaction when the app is in the background via a
      // Stream listener
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
        PushMessage pushMessage = PushMessage.fromJson(message.data);
        _decryptAndOpen(pushMessage.content);
      });

      // Get any messages which caused the application to open from
      // a terminated state.
      RemoteMessage initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        PushMessage pushMessage = PushMessage.fromJson(initialMessage.data);
        _decryptAndOpen(pushMessage.content);
      }
    }
  }

  void _initLocalNotification() {
    this._localNotificationSubscription = selectNotificationSubject.listen((String payload) async {
      _decryptAndOpen(payload);
    });
  }

  Future<String> _getEncryptionKey() async {
    final storage = new FlutterSecureStorage();
    return await storage.read(key: 'encryptionkey');
  }

  void _decryptAndOpen(String encryptedContent) async {
    String decrypted;

    try {
      decrypted = await decrypt(encryptedContent, await _getEncryptionKey());
    } catch (ex) {
      final snackBar = SnackBar(content: Text('Could not open QR-code, check if encryption keys match.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    if (decrypted != null) {
      _urlLaunch(decrypted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR-code receiver'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage(), settings: RouteSettings(name: 'SettingsPage')),
              );
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ),
    );
  }
}
