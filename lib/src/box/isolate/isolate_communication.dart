import 'package:hive/hive.dart';

class IsolateRequest<T> {
  final int operation;

  final T data;

  const IsolateRequest(this.operation, this.data);
}

class IsolateResponse<T> {
  final T data;

  final dynamic error;

  const IsolateResponse(this.data) : error = null;

  const IsolateResponse.error(this.error) : data = null;
}

class IsolateOperation {
  static const initialize = 0;
  static const getLength = 1;
  static const getKeys = 2;
  static const keyAt = 3;
  static const containsKey = 4;
  static const getValues = 5;
  static const valuesBetween = 6;
  static const watch = 7;
  static const get = 8;
  static const getAt = 9;
  static const toMap = 10;
  static const putAt = 11;
  static const putAll = 12;
  static const addAll = 13;
  static const deleteAt = 14;
  static const compact = 15;
  static const clear = 16;
  static const close = 17;
  static const deleteFromDisk = 18;
}

class RemoteBoxParameters {
  final String name;
  final bool lazy;
  final HiveCipher encryptionCipher;
  final KeyComparator keyComparator;
  final CompactionStrategy compactionStrategy;
  final bool crashRecovery;
  final String path;
  final Map<int, TypeAdapter> adapters;

  const RemoteBoxParameters({
    this.name,
    this.lazy,
    this.encryptionCipher,
    this.keyComparator,
    this.compactionStrategy,
    this.crashRecovery,
    this.path,
    this.adapters,
  });
}
