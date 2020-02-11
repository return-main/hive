import 'dart:io';
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
  List<Future<dynamic> Function(dynamic data)> operations;
  LocalBoxBase box;

  IsolateRunner() {
    operations = [
      //
      initialize, getLength, getKeys, keyAt, containsKey, getValues,
      valuesBetween, watch, get, getAt, toMap, putAt, putAll, addAll,
      deleteAt, compact, clear, close, deleteFromDisk
    ];
  }

  Future handleRequests(Stream requestStream, SendPort sendPort) async {
    await for (var request in requestStream) {
      IsolateResponse response;
      try {
        var req = request as IsolateRequest;
        //print('operation: ' + req.operation.toString());
        //print('data: ' + req.data.toString());
        var operation = operations[req.operation];
        var responseData = await operation(req.data);
        response = IsolateResponse(responseData);
      } catch (e) {
        response = IsolateResponse.error(e);
      }
      sendPort.send(response);
      if (!box.isOpen) {
        break;
      }
    }
  }

  Future<dynamic> initialize(dynamic data) async {
    if (box != null) {
      throw StateError('IsolateRunner is already initialized.');
    }
    var params = data as RemoteBoxParameters;
    /*if (params.lazy) {
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
    }*/
    box = await Hive.openBox('name', path: Directory.current.path);
  }

  Future<dynamic> getLength(dynamic _) {
    return Future.value(box.length);
  }

  Future<dynamic> getKeys(dynamic _) {
    return Future.value(box.keys);
  }

  Future<dynamic> keyAt(dynamic index) {
    return Future.value(box.keyAt(index as int));
  }

  Future<dynamic> containsKey(dynamic key) {
    return Future.value(box.containsKey(key));
  }

  Future<dynamic> getValues(dynamic _) {
    return Future.value((box as Box).values.toList());
  }

  Future<dynamic> valuesBetween(dynamic data) {
    var values = (box as Box).valuesBetween(startKey: data[0], endKey: data[1]);
    return Future.value(values);
  }

  Future<dynamic> watch(dynamic data) {
    var sendPort = data[0] as SendPort;
    var key = data[1];
    var subscription = box.watch(key: key).listen((event) {
      sendPort.send(event);
    });

    var receivePort = ReceivePort();
    receivePort.first.then((value) {
      subscription.cancel();
      receivePort.close();
    });

    return Future.value(receivePort.sendPort);
  }

  Future<dynamic> get(dynamic data) {
    if (box.isLazy) {
      return (box as LazyBox).get(data[0], defaultValue: data[1]);
    } else {
      var value = (box as Box).get(data[0], defaultValue: data[1]);
      return Future.value(value);
    }
  }

  Future<dynamic> getAt(dynamic index) {
    if (box.isLazy) {
      return (box as LazyBox).getAt(index as int);
    } else {
      var value = (box as Box).getAt(index as int);
      return Future.value(value);
    }
  }

  Future<dynamic> toMap(dynamic _) {
    return Future.value((box as Box).toMap());
  }

  Future<dynamic> putAt(dynamic data) {
    return box.putAt(data[0] as int, data[1]);
  }

  Future<dynamic> putAll(dynamic data) {
    return box.putAll(data[0] as Map, keysToDelete: data[1] as List);
  }

  Future<dynamic> addAll(dynamic values) {
    return box.addAll(values as List);
  }

  Future<dynamic> deleteAt(dynamic index) {
    return box.deleteAt(index as int);
  }

  Future<dynamic> compact(dynamic _) {
    return box.compact();
  }

  Future<dynamic> clear(dynamic _) {
    return box.clear();
  }

  Future<dynamic> close(dynamic _) {
    return box.close();
  }

  Future<dynamic> deleteFromDisk(dynamic _) {
    return box.deleteFromDisk();
  }
}
