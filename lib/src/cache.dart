import 'dart:async';
import 'package:mocha/src/cache_impl.dart';

/// Key value cache where values are loaded manually and stored until they
/// are evicted or manually invalidated.
abstract class Cache<K, V> {
  factory Cache({
    Duration expiresAfterWrite,
    int maximumSize
  }) {
    return new CacheImpl(
      expiresAfterWrite: expiresAfterWrite,
      maximumSize: maximumSize
    );
  }

  /// Retrieve a value from the cache given a key.
  ///
  /// Returns the value associated with the key if it is in the
  /// cache. Otherwise it returns null.
  V getIfPresent(K key);

  /// Retrieve a map of values given multiple keys.
  ///
  /// Returns a map of every key provided to its value. Values may
  /// be null if not present in the cache.
  Map<K, V> getAllPresent<T extends K>(Iterable<T> keys);

  /// Manually put a key, value into the cache.
  void put(K key, V value);

  /// Manually put a map of key, values into the cache.
  void putAll<T extends K, U extends V>(Map<T, U> map);

  /// Invalidate a key in the cache.
  void invalidate(K key);

  /// Invalidate multiple keys in the cache.
  void invalidateAll<T extends K>([Iterable<T> keys]);

  /// Represent that cache as a map of key, value pairs.
  Map<K, V> toMap();

  /// Get the approximate size of the cache.
  int get size;
}

/// A cache that can load values into the cache when they are not present.
abstract class LoadingCache<K, V> implements Cache<K, V> {
  factory LoadingCache(Refresher<K, V> refresher, {
    Duration expiresAfterWrite,
    int maximumSize
  }) {
    var delegate = new Cache<K, V>(
      expiresAfterWrite: expiresAfterWrite,
      maximumSize: maximumSize
    );
    return new LoadingCacheImpl(delegate, refresher);
  }

  /// Returns the value associated with the key in this cache, first loading
  /// the value into the cache if necessary.
  Future<V> get(K key);

  /// Returns a map of values associated with the keys, first loading those
  /// values into the cache if necessary.
  Future<Map<K, V>> getAll<T extends K>(Iterable<T> keys);

  /// Loads a new value for the key provided.
  Future<Null> refresh(K key);
}