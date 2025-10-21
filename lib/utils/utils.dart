import 'dart:convert';

import 'package:uuid/uuid.dart';

String getUniqueId() {
  var uuid = Uuid();
  var uniqueId = uuid.v4();
  Codec<String, String> stringToBase64 = utf8.fuse(base64);
  var uniqueString = stringToBase64.encode(uniqueId.substring(0, 16));
  return uniqueString;
}
