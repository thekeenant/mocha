# mocha

Mocha is a simple caching library for Dart.

Features

* Size-based eviction
* Time-based expiration (since last write)
* Asynchronously refresh values
* Automatic asynchronous loading of values into the cache
* Manually...
  * Evict/invalidate values
  * Populate the cache


## Usage

A simple usage example:

```dart
import 'dart:async';
import 'package:mocha/mocha.dart';

Future<String> expensiveOperation(int key) async {
  // pretend this is takes time to calculate
  var sq = key * key;
  return '$key^2 = $sq';
}

main() async {
  var cache = new LoadingCache<int, String>(
    expensiveOperation,
    maximumSize: 10,
    expiresAfterWrite: const Duration(minutes: 1)
  );

  print(await cache.get(4));
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/thekeenant/mocha
