import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

/// Create a [AndroidNotificationChannel] for heads up notifications
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'qr_receiver_high_importance_channel', // id
  'QR-code Notifications', // title
  'This channel is used notifications that bring QR-codes', // description
  importance: Importance.high,

);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

final PublishSubject<String> selectNotificationSubject = PublishSubject<String>();
