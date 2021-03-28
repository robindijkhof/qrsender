class PushMessage{
  String host;
  DateTime datetime;
  String content;

  PushMessage.fromJson(Map<String, dynamic> json){
    host = json['host'] ?? 'Unknown';
    datetime = DateTime.tryParse(json['datetime']);
    content = json['content'];
  }
}