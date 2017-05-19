import 'dart:async';

import 'package:mocha/mocha.dart';

main() async {
  var cache = new LoadingCache((key) async {
    return '$key is cached';
  }, expiresAfterWrite: const Duration(seconds: 1));

  // > '1 is cached'
  print(await cache.get(1));

  new Future.delayed(const Duration(seconds: 2), () async {
    // > null
    print(cache.getIfPresent(1));

    // populate 1 again
    await cache.refresh(1);

    // > '1 is cached'
    print(cache.getIfPresent(1));
  });
}
