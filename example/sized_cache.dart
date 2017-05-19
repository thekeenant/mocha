import 'dart:async';

import 'package:mocha/mocha.dart';

main() {
  var cache = new Cache<int, int>(maximumSize: 3);

  for (int i = 1; i <= 3; i++) {
    cache.put(i, i * i * i);
  }

  // looking good so far, 3 things in the cache
  print(cache.toMap());

  for (int i = 3; i <= 10; i++) {
    cache.put(i, i * i * i);
  }

  // the last 3 are cached, the rest are gone
  print(cache.toMap());
}
