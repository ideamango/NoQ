class ListItem {
  ListItem({this.itemName, this.isDone});

  String itemName;

  bool isDone;

  Map<String, dynamic> toJson() => {'itemName': itemName, 'isDone': isDone};

  static ListItem fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new ListItem(itemName: json['itemName'], isDone: json['isDone']);
  }
}
