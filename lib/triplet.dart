class Triplet<T1, T2, T3> {
  T1? item1;
  T2? item2;
  T3? item3;

  Triplet({this.item1, this.item2, this.item3});

  factory Triplet.fromJson(Map<String, dynamic> json) {
    return Triplet(
      item1: json['item1'],
      item2: json['item2'],
      item3: json['item3'],
    );
  }
}
