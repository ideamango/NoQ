class Message {
  Message({this.userId, this.content, this.time});

  String userId;
  String content;
  DateTime time;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'content': content,
        'time': time.millisecondsSinceEpoch
      };

  static Message fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new Message(
        userId: json['userId'],
        content: json['content'],
        time: new DateTime.fromMillisecondsSinceEpoch(json['time']));
  }
}
