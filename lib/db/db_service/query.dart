import '../../enum/comparator.dart';

class RangeQuery {
  RangeQuery({this.key, this.value, this.comparatorOperator});

  String key;
  int value;
  Comparator comparatorOperator;
}

class MultiValuedQuery {
  MultiValuedQuery({this.key, this.values, this.partialMatch});

  String key;
  List<dynamic> values;
  bool partialMatch;
}
