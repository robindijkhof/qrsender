// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qrcode_receiver/encryption_utils.dart';
import 'package:qrcode_receiver/model/push_message.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cryptography/cryptography.dart';



/// Define a top-level named handler which background/terminated messages will
/// call.
///
/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler); // Not sure what to do in the background

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String token = '';

  TextEditingController _controller;

    Future<SecretKey> getKey() async{
      final pbkdf2 = Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: 100000,
        bits: 256,
      );

      // Password we want to hash
      final secretKey = SecretKey(utf8.encode('key'));

      // A random salt
      final salt = [0, 72, 16, 170, 232, 145, 179, 47, 241, 92, 75, 146, 25, 0, 193, 176];

      // Calculate a hash that can be stored in the database
      final newSecretKey = await pbkdf2.deriveKey(
        secretKey: secretKey,
        nonce: salt,
      );

      return Future<SecretKey>.value(newSecretKey);
    }

  void _incrementCounter() async{
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });






    // final algorithm = AesGcm.with256bits();
    //
    // // final encrypted = base64Decode('1MdEsqwqh4bUTlfpIk12SeziA9Pw');
    // // Uint8List ciphertext  = encrypted.sublist(0, encrypted.length - 16);
    // // Uint8List mac = encrypted.sublist(encrypted.length - 16);
    // // Uint8List iv = base64Decode('xgBc/QD1jE/s1/8A'); // should als be concatenated, e.g. iv | ciphertext | tag
    // // SecretBox secretBox = new SecretBox(ciphertext, nonce: iv, mac: new Mac(mac));
    //
    // // 16 salt, 12 nonce/vi, N content, 16 mac/tag
    // final encrypted = base64Decode('AEgQquiRsy/xXEuSGQDBsA==xgBc/QD1jE/s1/8A1MdEsqwqh4bUTlfpIk12SeziA9Pw');
    // // final secretBox = SecretBox.fromConcatenation(encrypted, nonceLength: 12, macLength: 16); does not work due to a bug
    //
    // Uint8List ciphertext  = encrypted.sublist(28, encrypted.length - 16);
    // Uint8List mac = encrypted.sublist(encrypted.length - 16);
    // Uint8List iv = encrypted.sublist(16, 28);
    // Uint8List salt = encrypted.sublist(0, 16);
    // SecretBox secretBox = new SecretBox(ciphertext, nonce: iv, mac: new Mac(mac));
    //
    // // // Encrypt
    // final data = await algorithm.decrypt(
    //   secretBox,
    //   secretKey: await getKey(),
    // );
    //
    //
    // String res = utf8.decode(data);
    String tt = await decrypt('dummy', 'key');

    String asd = 'test';
    // print('Nonce: ${secretBox.nonce}')
    // print('Ciphertext: ${secretBox.cipherText}')
    // print('MAC: ${secretBox.mac.bytes}')
    //
    // // Decrypt
    // final clearText = await algorithm.encrypt(
    //   secretBox,
    //   secretKey: secretKey,
    // );
    // print('Cleartext: $clearText');
  }

  void urlLaunch(String content) async {
    String url = Uri.encodeFull('irma://qr/json/$content');

    launch(url).then((success) {
      if(!success){
        final snackBar =
        SnackBar(content: Text('IRMA could not be opened. Is it installed?'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      print(success);
    });

  }

  void initMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        PushMessage pushMessage = PushMessage.fromJson(message.data);

        String decrypted = await decrypt(pushMessage.data, 'asdasd');
        urlLaunch(pushMessage.content);

        // if (message.notification != null) {
        //   print('Message also contained a notification: ${message.notification}');
        // }

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => OpenIrmaPage(pushMessage: pushMessage)),
        // );
      });

      // Also handle any interaction when the app is in the background via a
      // Stream listener
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        PushMessage pushMessage = PushMessage.fromJson(message.data);

        urlLaunch(pushMessage.content);

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => OpenIrmaPage(pushMessage: pushMessage)),
        // );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = new TextEditingController(text: 'Token');

    initMessaging();

    FirebaseMessaging.instance.getToken().then((value) => {
          setState(() {
            _controller.text = value;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            TextField(
              controller: _controller,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
