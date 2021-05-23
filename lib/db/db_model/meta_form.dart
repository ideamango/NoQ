class MetaForm {
  MetaForm(
      {this.id,
      this.name,
      this.description,
      this.autoApproved,
      this.allowedOnline});

  //just need an id which is unique even if later phone or firebase id changes
  String id;
  String name;
  String description;
  bool autoApproved;
  bool allowedOnline;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'autoApproved': autoApproved,
        'allowedOnline': allowedOnline
      };

  static MetaForm fromJson(Map<String, dynamic> json) {
    return new MetaForm(
        id: json['id'],
        name: json['name'],
        description: json["description"],
        autoApproved: json['autoApproved'],
        allowedOnline: json['allowedOnline']);
  }
}
