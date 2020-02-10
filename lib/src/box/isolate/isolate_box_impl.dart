import 'dart:async';
import 'dart:isolate';

import 'package:hive/hive.dart';
import 'package:hive/src/box/box_base_impl.dart';
import 'package:hive/src/box/isolate/isolate_communication.dart';
import 'package:hive/src/box/isolate/isolate_runner.dart';
import 'package:hive/src/hive_impl.dart';

class IsolateBoxImpl<E> extends BoxBaseImpl<E> implements IsolateBox<E> {
  Isolate _isolate;
  SendPort _sendPort;
  Stream _resultStream;
  StreamSubscription _resultStreamSubscription;

  @override
  final bool isLazy;

  @override
  final bool isIsolate = true;

  @override
  final String path;

  IsolateBoxImpl(HiveImpl hive, String name, this.isLazy, this.path)
      : super(hive, name);

  Future<T> sendRequest<T, R>(int operation, [R data]) async {
    checkOpen();
    var request = IsolateRequest(operation, data);
    _sendPort.send(request);

    var response = await _resultStream.first as IsolateResponse<T>;
    if (response.error != null) {
      throw response.error;
    }
    return response.data;
  }

  @override
  Future<void> initialize() async {
    var receivePort = ReceivePort();
    _isolate = await Isolate.spawn(createIsolateRunner, receivePort.sendPort);
    _resultStream = receivePort.asBroadcastStream(onListen: (sub) {
      _resultStreamSubscription = sub;
    });
    _sendPort = await _resultStream.first as SendPort;

    var params = RemoteBoxParameters(name: name, lazy: isLazy);
    await sendRequest(IsolateOperation.initialize, params);
  }

  void _shutdown() {
    _isolate.kill();
    _resultStreamSubscription.cancel();
    closeInternal();
  }

  @override
  Future<int> get length {
    return sendRequest(IsolateOperation.getLength);
  }

  @override
  Future<bool> get isEmpty async {
    return await length == 0;
  }

  @override
  Future<bool> get isNotEmpty async {
    return await length != 0;
  }

  @override
  Future<Iterable> get keys {
    return sendRequest(IsolateOperation.getKeys);
  }

  @override
  Future keyAt(int index) {
    return sendRequest(IsolateOperation.keyAt, index);
  }

  @override
  Future<bool> containsKey(key) {
    return sendRequest(IsolateOperation.containsKey, key);
  }

  @override
  Future<Iterable<E>> get values async {
    _checkNonLazyForMultiValueAccess();
    var values = await sendRequest<Iterable, void>(IsolateOperation.getValues);
    return values.cast();
  }

  @override
  Future<Iterable<E>> valuesBetween({startKey, endKey}) async {
    _checkNonLazyForMultiValueAccess();
    var values = await sendRequest<Iterable, void>(
        IsolateOperation.valuesBetween, [startKey, endKey]);
    return values.cast();
  }

  @override
  Future<E> get(key, {E defaultValue}) async {
    var value = await sendRequest(IsolateOperation.get, [key, defaultValue]);
    return value as E;
  }

  @override
  Future<E> getAt(int index) async {
    var value = await sendRequest(IsolateOperation.getAt, index);
    return value as E;
  }

  @override
  Future<Map<dynamic, E>> toMap() async {
    _checkNonLazyForMultiValueAccess();
    var map = await sendRequest<Map, void>(IsolateOperation.toMap);
    return map.cast();
  }

  @override
  Future<void> putAt(int index, E value) {
    return sendRequest(IsolateOperation.putAt, [index, value]);
  }

  @override
  Future<void> putAll(Map<dynamic, E> entries) {
    return sendRequest(IsolateOperation.putAll, entries);
  }

  @override
  Future<void> addAll(Iterable<E> values) {
    return sendRequest(IsolateOperation.addAll, values);
  }

  @override
  Future<void> deleteAt(int index) {
    return sendRequest(IsolateOperation.deleteAt, index);
  }

  @override
  Future<void> deleteAll(Iterable keys) {
    return sendRequest(IsolateOperation.deleteAll, keys);
  }

  @override
  Future<void> compact() {
    return sendRequest(IsolateOperation.compact);
  }

  @override
  Future<int> clear() {
    return sendRequest(IsolateOperation.clear);
  }

  @override
  Future<void> close() async {
    await sendRequest(IsolateOperation.close);
    _shutdown();
  }

  @override
  Future<void> deleteFromDisk() async {
    await sendRequest(IsolateOperation.deleteFromDisk);
    _shutdown();
  }

  @override
  Stream<BoxEvent> watch({key}) {
    // TODO: implement watch
    throw UnimplementedError();
  }

  void _checkNonLazyForMultiValueAccess() {
    if (isLazy) {
      throw HiveError(
          'Only non-lazy boxes allow access to multiple values at once.');
    }
  }
}
