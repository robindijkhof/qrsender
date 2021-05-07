import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qrcode_receiver/utils.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  Stream<bool> $isAuthenticated =
      isAuthenticated('Please authenticate to open the settings')
          .asStream()
          .asBroadcastStream();

  @override
  void initState() {
    super.initState();

    $isAuthenticated.listen((event) {
      if(!event){
        final snackBar =
        SnackBar(content: Text('Could not authenticate'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop()),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: StreamBuilder<bool>(
          stream: $isAuthenticated,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data) {
                return _getSettingsBody();
              } else {
                return Text('not authenticated');
              }
            } else {
              return Text('Waiting');
            }
          }),
    );
  }

  Future<String> _getEncryptionKey() async {
    final storage = new FlutterSecureStorage();
    String key = await storage.read(key: 'encryptionkey');
    if(key == null){
      key = '';
    }
    return Future.value(key);
  }

  Future<void> _setEncryptionKey(String key) async {
    final storage = new FlutterSecureStorage();
    return await storage.write(key: 'encryptionkey', value: key);
  }

  void _sendRegistrationToken() async {
    String token = await FirebaseMessaging.instance.getToken();

    final MailOptions mailOptions = MailOptions(
      body: 'Your device registration token: \n\n' + token,
      subject: 'QR-Sender',
      isHTML: false,
    );

    final MailerResponse response = await FlutterMailer.send(mailOptions);
    //
    // final Email email = Email(
    //   subject: 'QR-Sender',
    //   body: 'Your device registration token: \n\n' + token,
    // );
    // await FlutterEmailSender.send(email);
  }

  Widget _getSettingsBody() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<String>(
                future: _getEncryptionKey(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return TextFormField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Encryption key'),
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return 'Can not be empty.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _setEncryptionKey(value);
                      },
                      initialValue: snapshot.data ?? '',
                    );
                  } else {
                    return Text('Loading...');
                  }
                }),
          ),
          Divider(),
          ListTile(
            title: Text('Mail my registration token'),
            trailing: IconButton(
              onPressed: () {
                _sendRegistrationToken();
              },
              icon: Icon(Icons.send),
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
