import 'dart:async';

import 'package:mocha/src/abstract_cache.dart';
import 'package:mocha/src/cache.dart';

typedef void Invalidator<K>(K key);

class Reference {
  final DateTime timestamp;

  Reference() : this.timestamp = new DateTime.now();
}

class CacheImpl<K, V> extends AbstractCache<K, V> {
  Map<K, V> _keyToValue = {};
  Map<K, Reference> _refs = {};
  Duration expiresAfterWrite;
  int maximumSize;

  CacheImpl({
    this.expiresAfterWrite,
    this.maximumSize
  });

  void _evict() {
    K chosen;
    DateTime time;

    _refs.forEach((key, ref) {
      if (chosen == null || ref.timestamp.isBefore(time)) {
        chosen = key;
        time = ref.timestamp;
      }
    });

    if (chosen != null) {
      invalidate(chosen);
    }
  }

  @override
  V getIfPresent(K key) {
    var ref = _refs[key];

    if (ref != null) {
      if (expiresAfterWrite != null) {
        var now = new DateTime.now();
        var expiry = ref.timestamp.add(expiresAfterWrite);
        if (now.isAfter(expiry)) {
          invalidate(key);
        }
      }
    }

    return _keyToValue[key];
  }

  @override
  Future<V> getOrPut(K key, Callable<K, V> callable) async {
    V value = getIfPresent(key);
    if (value == null) {
      value = await callable(key);
      put(key, value);
    }
    return value;
  }

  @override
  void put(K key, V value) {
    if (maximumSize != null && size + 1 > maximumSize) {
      _evict();
    }

    _refs[key] = new Reference();
    _keyToValue[key] = value;
  }

  @override
  void invalidate(K key) {
    var ref = _refs.remove(key);
    _keyToValue.remove(key);
  }

  @override
  int get size => _keyToValue.length;

  @override
  Map<K, V> toMap() {
    return _keyToValue;
  }
}

class LoadingCacheImpl<K, V> extends AbstractLoadingCache<K, V> {
  final Cache<K, V> _delegate;
  Callable<K, V> _callable;

  LoadingCacheImpl(this._delegate, this._callable);

  @override
  Future<V> get(K key) async {
    V value = getIfPresent(key);
    if (value == null) {
      value = await _callable(key);
      put(key, value);
    }
    return value;
  }

  @override
  Future<Null> refresh(K key) async {
    put(key, await _callable(key));
  }

  // delegate

  @override
  Map<K, V> getAllPresent<T extends K>(Iterable<K> keys) {
    return _delegate.getAllPresent(keys);
  }

  @override
  V getIfPresent(K key) {
    return _delegate.getIfPresent(key);
  }

  @override
  void invalidate(K key) {
    _delegate.invalidate(key);
  }

  @override
  void invalidateAll<T extends K>([Iterable<K> keys]) {
    _delegate.invalidateAll(keys);
  }

  @override
  void put(K key, V value) {
    _delegate.put(key, value);
  }

  @override
  void putAll<T extends K, U extends V>(Map<T, U> map) {
    _delegate.putAll(map);
  }

  @override
  Future<V> getOrPut(K key, Callable<K, V> callable) async {
    return await _delegate.getOrPut(key, callable);
  }

  @override
  Future<Map<K, V>> getOrPutAll<T extends dynamic>(Iterable<K> keys, Callable<K, V> callable) async {
    return await _delegate.getOrPutAll(keys, callable);
  }

  @override
  int get size => _delegate.size;

  @override
  Map<K, V> toMap() {
    return _delegate.toMap();
  }
}