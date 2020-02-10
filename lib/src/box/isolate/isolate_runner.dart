import 'dart:isolate';

import 'package:hive/hive.dart';

class IsolateRequest<T> {
  final int operation;

  final T data;

  IsolateRequest(this.operation, this.data);
}

class IsolateResponse<T> {
  final T data;

  final dynamic error;

  IsolateResponse(this.data) : error = null;

  IsolateResponse.error(this.error) : data = null;
}

class IsolateOperation {
  static const initialize = 0;
  static const getLength = 1;
  static const keyAt = 2;
  static const containsKey = 3;
  static const getValues = 4;
  static const valuesBetween = 5;
  static const get = 6;
  static const getAt = 7;
  static const putAt = 6;
  static const putAll = 7;
  static const addAll = 8;
  static const deleteAll = 9;
  static const compact = 10;
  static const clear = 11;
  static const close = 12;
  static const deleteFromDisk = 13;
  static const toMap = 11;
}

class RemoteBoxParameters {
  final bool lazy;
  final HiveCipher encryptionCipher;
  final KeyComparator keyComparator;
  final CompactionStrategy compactionStrategy;
  final bool crashRecovery;
  final String path;
  final Map<int, TypeAdapter> adapters;

  const RemoteBoxParameters(
    this.lazy,
    this.encryptionCipher,
    this.keyComparator,
    this.compactionStrategy,
    this.crashRecovery,
    this.path,
    this.adapters,
  );
}

class IsolateRunner {
  ReceivePort receivePort;
  LocalBoxBase box;

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
    box = await Hive.openBox(
      params.name,
      encryptionCipher: params.encryptionCipher,
      keyComparator: params.keyComparator,
      compactionStrategy: params.compactionStrategy,
      crashRecovery: params.crashRecovery,
      path: params.path,
    );

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
    return IsolateResponse(
      (box as Box).valuesBetween(startKey: keys[0], endKey: keys[1]),
    );
  }
}
