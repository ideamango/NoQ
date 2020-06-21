class MetaUser {
  MetaUser({this.id, this.name, this.ph});

  //just need an id which is unique even if later phone or firebase id changes
  String id;
  String name;
  String ph;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'ph': ph};

  static MetaUser fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new MetaUser(id: json['id'], name: json['name'], ph: json['ph']);
  }
}
