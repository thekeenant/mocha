import 'dart:async';

import 'package:mocha/src/abstract_cache.dart';
import 'package:mocha/src/cache.dart';

typedef void Invalidator<K>(K key);
typedef Future<V> Refresher<K, V>(K key);

class Reference {
  final DateTime timestamp;
  Timer expireFuture;

  Reference(Object key, Invalidator invalidator, {Duration expire}) : this.timestamp = new DateTime.now() {
    if (expire != null) {
      expireFuture = new Timer(expire, () => invalidator(key));
    }
  }

  void invalidate() {
    if (expireFuture != null) {
      expireFuture.cancel();
    }
  }
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
  void put(K key, V value) {
    if (maximumSize != null && size + 1 > maximumSize) {
      _evict();
    }

    _refs[key] = new Reference(key, invalidate, expire: expiresAfterWrite);
    _keyToValue[key] = value;
  }

  @override
  void invalidate(K key) {
    Reference ref = _refs[key];
    _refs.remove(key);
    ref?.invalidate();
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
  Refresher<K, V> _refresher;

  LoadingCacheImpl(this._delegate, this._refresher);

  @override
  Future<V> get(K key) async {
    V value = getIfPresent(key);
    if (value == null) {
      value = await _refresher(key);
      put(key, value);
    }
    return value;
  }

  @override
  Future<Null> refresh(K key) async {
    put(key, await _refresher(key));
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
  int get size => _delegate.size;

  @override
  Map<K, V> toMap() {
    return _delegate.toMap();
  }
}