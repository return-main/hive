import 'dart:isolate';

import 'package:hive/hive.dart';
import 'package:hive/src/box/isolate/isolate_communication.dart';

Future createIsolateRunner(SendPort sendPort) async {
  var receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  var runner = IsolateRunner();
  await runner.handleRequests(receivePort, sendPort);
}

class IsolateRunner {
  LocalBoxBase box;

  Future handleRequests(Stream requestStream, SendPort sendPort) async {
    await for (var request in requestStream) {
      IsolateResponse response;
      try {
        response = await handle(request as IsolateRequest);
      } catch (e) {
        response = IsolateResponse.error(e);
      }
      sendPort.send(response);
      if (!box.isOpen) {
        break;
      }
    }
  }

  Future<IsolateResponse> handle(IsolateRequest request) async {
    switch (request.operation) {
      case IsolateOperation.initialize:
        return initialize(request.data as RemoteBoxParameters);
      case IsolateOperation.getLength:
        return getLength();
      case IsolateOperation.keyAt:
        return keyAt(request.data as int);
      case IsolateOperation.containsKey:
        return containsKey(request.data as dynamic);
      case IsolateOperation.getValues:
        return getValues();
    }
  }

  Future<IsolateResponse> initialize(RemoteBoxParameters params) async {
    if (box != null) {
      throw StateError('IsolateRunner is already initialized.');
    }
    if (params.lazy) {
      box = await Hive.openLazyBox(
        params.name,
        encryptionCipher: params.encryptionCipher,
        keyComparator: params.keyComparator,
        compactionStrategy: params.compactionStrategy,
        crashRecovery: params.crashRecovery,
        path: params.path,
      );
    } else {
      box = await Hive.openBox(
        params.name,
        encryptionCipher: params.encryptionCipher,
        keyComparator: params.keyComparator,
        compactionStrategy: params.compactionStrategy,
        crashRecovery: params.crashRecovery,
        path: params.path,
      );
    }

    return IsolateResponse(null);
  }

  IsolateResponse getLength() {
    return IsolateResponse(box.length);
  }

  IsolateResponse keyAt(int index) {
    return IsolateResponse(box.keyAt(index));
  }

  IsolateResponse containsKey(dynamic key) {
    return IsolateResponse(box.containsKey(key));
  }

  IsolateResponse getValues() {
    return IsolateResponse((box as Box).values.toList());
  }

  IsolateResponse valuesBetween(List<dynamic> keys) {
    var values = (box as Box).valuesBetween(startKey: keys[0], endKey: keys[1]);
    return IsolateResponse(values);
  }

  Future<IsolateResponse> get(String key, dynamic defaultValue) async {
    dynamic value;
    if (box.isLazy) {
      value = await (box as LazyBox).get(key, defaultValue: defaultValue);
    } else {
      value = (box as Box).get(key, defaultValue: defaultValue);
    }
    return IsolateResponse(value);
  }

  Future<IsolateResponse> getAt(int index) async {
    dynamic value;
    if (box.isLazy) {
      value = await (box as LazyBox).getAt(index);
    } else {
      value = (box as Box).getAt(index);
    }
    return IsolateResponse(value);
  }

  IsolateResponse toMap() {
    return IsolateResponse((box as Box).toMap());
  }

  Future<IsolateResponse> putAt(int index, dynamic value) async {
    await box.putAt(index, value);
    return IsolateResponse(null);
  }

  Future<IsolateResponse> putAll(Map<String, dynamic> entries) async {
    await box.putAll(entries);
    return IsolateResponse(null);
  }

  Future<IsolateResponse> addAll(List<dynamic> values) async {
    await box.addAll(values);
    return IsolateResponse(null);
  }

  Future<IsolateResponse> deleteAt(int index) async {
    await box.deleteAt(index);
    return IsolateResponse(null);
  }

  Future<IsolateResponse> deleteAll(List<dynamic> keys) async {
    await box.deleteAll(keys);
    return IsolateResponse(null);
  }

  Future<IsolateResponse> compact() async {
    await box.compact();
    return IsolateResponse(null);
  }

  Future<IsolateResponse> clear() async {
    await box.clear();
    return IsolateResponse(null);
  }

  Future<IsolateResponse> close() async {
    await box.close();
    return IsolateResponse(null);
  }

  Future<IsolateResponse> deleteFromDisk() async {
    await box.deleteFromDisk();
    return IsolateResponse(null);
  }
}
