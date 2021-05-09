import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qrcode_receiver/model/push_message.dart';
import 'package:qrcode_receiver/pages/settings_page.dart';
import 'package:qrcode_receiver/simple_logger.dart';
import 'package:qrcode_receiver/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';


import '../encryption_utils.dart';
import '../local_notification.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription _localNotificationSubscription;

  final Stream<List<DateTime>> _$logs = SimpleLogger().getLogs();

  final DateFormat formatter = DateFormat('EEEE d MMMM yyyy - HH:mm');



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
    log('launch start: ${DateTime.now().millisecondsSinceEpoch}');

    bool validURL = Uri.parse(content).hasAbsolutePath;

    String url;
    String error;
    if(validURL){
      url = content;
      error = 'QR-code could not be opened by an app.';
    }else{
      url = Uri.encodeFull('irma://qr/json/$content');
      error = 'IRMA could not be opened. Is it installed?';
    }

    log('launch middel: ${DateTime.now().millisecondsSinceEpoch}');


    launch(url).then((success) {
      log('launch end: ${DateTime.now().millisecondsSinceEpoch}');

      if (!success) {
        final snackBar = SnackBar(content: Text(error));
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
        log('on message');
        SimpleLogger().logNow();
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
      log('noti subscription: ${DateTime.now().millisecondsSinceEpoch}');
      _decryptAndOpen(payload);
    });
  }

  Future<String> _getEncryptionKey() async {
    final storage = new FlutterSecureStorage();
    return await storage.read(key: 'encryptionkey');
  }

  void _decryptAndOpen(String encryptedContent) async {
    log('decrypt and open start: ${DateTime.now().millisecondsSinceEpoch}');
    String decrypted;

    showLoaderDialog(context);
    // await Future.delayed(Duration(milliseconds: 1000)); // Without the dialog is not presented.

    try {
      decrypted = await compute(decryptSingleArgument, [encryptedContent, await _getEncryptionKey()]);
      // decrypted = await decrypt(encryptedContent, await _getEncryptionKey());
    } catch (ex) {
      final snackBar = SnackBar(content: Text('Could not open QR-code, check if encryption keys match.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } finally{
      Navigator.pop(context);
    }

    log('decrypt and open middel: ${DateTime.now().millisecondsSinceEpoch}');


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
      body: Column(
        children: [
          FlatButton(onPressed: () {test();}, child: Text('test')),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('QR-code log', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          StreamBuilder<List<DateTime>>(
            stream: _$logs,
            builder: (BuildContext context, AsyncSnapshot<List<DateTime>> snapshot) {
              if(snapshot.hasData){
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(formatter.format(snapshot.data[index])),
                      );
                    },
                  ),
                );
              }else{
                return Text('Loading...');
              }
            },
          ),
        ],
      ),
    );
  }

  test(){
    showLoaderDialog(context);
  }

}
