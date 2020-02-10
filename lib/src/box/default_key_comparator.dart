import 'package:hive/hive.dart';

class DefaultKeyComparator implements KeyComparator {
  const DefaultKeyComparator();

  @override
  int compareKeys(key1, key2) {
    if (key1 is int) {
      if (key2 is int) {
        return key1.compareTo(key2);
      } else {
        return -1;
      }
    } else if (key2 is String) {
      return (key1 as String).compareTo(key2);
    } else {
      return 1;
    }
  }
}
