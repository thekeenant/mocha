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
