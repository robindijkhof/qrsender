import 'package:flutter/widgets.dart';
import 'package:qrcode_receiver/model/push_message.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenIrmaPage extends StatefulWidget {
  final PushMessage pushMessage;


  const OpenIrmaPage({Key key, @required this.pushMessage}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OpenIrmaPageState();
}

class _OpenIrmaPageState extends State<OpenIrmaPage> {
  @override
  void initState() {
    super.initState();

    urlLaunch(widget.pushMessage.content);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text('hello there, the right app should be opend');
  }

  void urlLaunch(String content){
    String url = Uri.encodeFull('irma://qr/json/$content');
    launch(url).then((value){
      print(value);
      Navigator.of(context).pop();
    });
  }

}