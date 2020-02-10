part of hive;

abstract class LocalBoxBase<E> extends BoxBase<E> {
  /// The number of entries in the box.
  int get length;

  /// Returns `true` if there are no entries in this box.
  bool get isEmpty;

  /// Returns true if there is at least one entries in this box.
  bool get isNotEmpty;

  /// All the keys in the box.
  ///
  /// The keys are sorted alphabetically in ascending order.
  Iterable<dynamic> get keys;

  /// Get the n-th key in the box.
  dynamic keyAt(int index);

  /// Checks whether the box contains the [key].
  bool containsKey(dynamic key);
}
