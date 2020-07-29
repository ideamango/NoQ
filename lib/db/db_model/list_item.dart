class ListItem {
  ListItem({this.itemName, this.quantity, this.isDone});

  String itemName;
  String quantity;
  bool isDone;

  Map<String, dynamic> toJson() =>
      {'itemName': itemName, 'quantity': quantity, 'isDone': isDone};

  static ListItem fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new ListItem(
        itemName: json['itemName'],
        quantity: json['quantity'],
        isDone: json['isDone']);
  }
}
