import 'dart:async';
import 'package:mocha/mocha.dart';

main() {
  var cache = new Cache<int, String>(
    expiresAfterWrite: const Duration(seconds: 1)
  );

  // > null
  print(cache.getIfPresent(1));

  // put into the cache manually
  cache.put(1, 'cached');

  // > 'cached'
  print(cache.getIfPresent(1));

  // wait until it is expired
  new Future.delayed(const Duration(seconds: 2), () {
    // > null
    print(cache.getIfPresent(1));
  });
}
