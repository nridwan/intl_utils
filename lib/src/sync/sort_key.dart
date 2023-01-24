import 'dart:convert';

import 'package:collection/collection.dart';

String sortARB(Map<String, dynamic> contents,
    {int Function(String, String)? compareFunction,
    bool caseInsensitive = false,
    bool naturalOrdering = false,
    bool descendingOrdering = false}) {
  compareFunction ??= (a, b) =>
      _commonSorts(a, b, caseInsensitive, naturalOrdering, descendingOrdering);

  final sorted = <String, dynamic>{};

  final keys = contents.keys.where((key) => !key.startsWith('@')).toList()
    ..sort(compareFunction);

  contents.keys.where((key) => key.startsWith('@@')).toList()
    ..sort(compareFunction)
    ..forEach((key) {
      sorted[key] = contents[key];
    });
  for (final key in keys) {
    sorted[key] = contents[key];
    if (contents.containsKey('@$key')) {
      sorted['@$key'] = contents['@$key'];
    }
  }

  final encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(sorted);
}

int _commonSorts(String a, String b, bool isCaseInsensitive,
    bool isNaturalOrdering, bool isDescending) {
  var ascending = 1;
  if (isDescending) {
    ascending = -1;
  }
  if (isCaseInsensitive) {
    a = a.toLowerCase();
    b = b.toLowerCase();
  }

  if (isNaturalOrdering) {
    return ascending * compareNatural(a, b);
  } else {
    return ascending * a.compareTo(b);
  }
}
