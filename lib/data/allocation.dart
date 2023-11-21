import 'package:libra_sheet/data/category.dart';

class Allocation {
  final int key;
  final String name;
  final Category? category;
  final int value;

  const Allocation({
    this.key = 0,
    required this.name,
    required this.category,
    required this.value,
  });

  @override
  String toString() {
    return "Allocation($key, $name: $value ${category?.name})";
  }
}

class MutableAllocation implements Allocation {
  @override
  int key;

  @override
  String name;

  @override
  Category? category;

  @override
  int value;

  MutableAllocation({
    this.key = 0,
    this.name = '',
    this.category,
    this.value = 0,
  });

  @override
  String toString() {
    return "MAllocation($key, $name, $value, ${category?.name})";
  }

  Allocation withKey(int key) {
    return Allocation(key: key, name: name, category: category, value: value);
  }
}
