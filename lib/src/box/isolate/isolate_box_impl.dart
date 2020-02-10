import 'package:hive/hive.dart';
import 'package:hive/src/box/box_base_impl.dart';
import 'package:hive/src/hive_impl.dart';

class IsolateBoxImpl<E> extends BoxBaseImpl<E> {
  IsolateBoxImpl(HiveImpl hive, String name) : super(hive, name);

  @override
  Future<int> add(E value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future<Iterable<int>> addAll(Iterable<E> values) {
    // TODO: implement addAll
    throw UnimplementedError();
  }

  @override
  Future<int> clear() {
    // TODO: implement clear
    throw UnimplementedError();
  }

  @override
  Future<void> close() {
    // TODO: implement close
    throw UnimplementedError();
  }

  @override
  Future<void> compact() {
    // TODO: implement compact
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAll(Iterable keys) {
    // TODO: implement deleteAll
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAt(int index) {
    // TODO: implement deleteAt
    throw UnimplementedError();
  }

  @override
  Future<void> deleteFromDisk() {
    // TODO: implement deleteFromDisk
    throw UnimplementedError();
  }

  @override
  Future<void> initialize() {
    // TODO: implement initialize
    throw UnimplementedError();
  }

  @override
  // TODO: implement isIsolate
  bool get isIsolate => throw UnimplementedError();

  @override
  // TODO: implement isLazy
  bool get isLazy => throw UnimplementedError();

  @override
  // TODO: implement path
  String get path => throw UnimplementedError();

  @override
  Future<void> putAll(Map<dynamic, E> entries) {
    // TODO: implement putAll
    throw UnimplementedError();
  }

  @override
  Future<void> putAt(int index, E value) {
    // TODO: implement putAt
    throw UnimplementedError();
  }

  @override
  Stream<BoxEvent> watch({key}) {
    // TODO: implement watch
    throw UnimplementedError();
  }
}
