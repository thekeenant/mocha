import 'dart:async';
import 'package:mocha/src/cache.dart';

/// An abstract class extending [Cache] which makes it easier for the
/// programmer to implement their own [Cache].
abstract class AbstractCache<K, V> implements Cache<K, V> {
  @override
  Map<K, V> getAllPresent<T extends K>(Iterable<T> keys) {
    return new Map.fromIterable(keys, value: (key) => getIfPresent(key));
  }

  @override
  void invalidateAll<T extends K>([Iterable<T> keys]) {
    keys.forEach((key) => invalidate(key));
  }

  @override
  void putAll<T extends K, U extends V>(Map<T, U> map) {
    map.forEach((key, value) => put(key, value));
  }

  @override
  Future<Map<K, V>> getOrPutAll<T extends K>(Iterable<K> keys, Callable<K, V> callable) async {
    var map = <K, V>{};

    for (var key in keys) {
      map[key] = await getOrPut(key, callable);
    }

    return map;
  }
}

/// An abstract class extending [LoadingCache] which makes it easier for the
/// programmer to implement their own [LoadingCache].
abstract class AbstractLoadingCache<K, V> implements AbstractCache<K, V>, LoadingCache<K, V> {
  @override
  Future<Map<K, V>> getAll<T extends K>(Iterable<K> keys) async {
    var map = <K, V>{};

    for (var key in keys) {
      map[key] = await get(key);
    }

    return map;
  }
}