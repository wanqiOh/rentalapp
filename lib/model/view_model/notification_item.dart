class NotificationsItem {
  String title;
  String id;
  String content;
  int clicked;
  int receivedDateTime;

  NotificationsItem(
      {this.title, this.id, this.content, this.clicked, this.receivedDateTime});

  factory NotificationsItem.fromJson(dynamic json) => NotificationsItem(
        title: json['headings']['en'],
        id: json['id'],
        content: json['contents']['en'],
        clicked: json['converted'],
        receivedDateTime: json['completed_at'],
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'content': content,
        'converted': clicked,
        'completed': receivedDateTime,
      };

  @override
  List<Object> get props => [id, title, content, clicked, receivedDateTime];
}
