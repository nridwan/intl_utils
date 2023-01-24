import 'dart:convert';

Map<String, dynamic> appendNewKeys(
    Map<String, dynamic> mainARB, Map<String, dynamic> newARB) {
  void addKey(String key) {
    String mainKey, propertiesKey;
    if (key.startsWith('@')) {
      mainKey = key.substring(1);
      propertiesKey = key;
    } else {
      mainKey = key;
      propertiesKey = '@$key';
    }
    mainARB[mainKey] = newARB[mainKey];
    mainARB[propertiesKey] = newARB[propertiesKey];
  }

  for (var key in newARB.keys) {
    if (mainARB[key] == null) {
      addKey(key);
    }
  }

  return mainARB;
}
