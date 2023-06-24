import 'dart:io';
import 'package:postcreator/utils/simple_io.dart';
import 'package:postcreator/utils/simple_keys.dart';

void main() {
  StringBuffer sb = StringBuffer();
  String id1 = generateSignId(20);
  String id2 = generateSignId(20);
  String key = encodeHashKey(generateHashKey(1 << 16));
  String id3 = generateSignId(10);
  String key1 = encodeHashKey(generateHashKey(1 << 12));
  sb.write("String signIn=\"$id1\";\n");
  sb.write("String signOut=\"$id2\";\n");
  sb.write("String hdKey=\"$key\";\n");
  sb.write("String stSign=\"$id3\";\n");
  sb.write("String stKey=\"$key1\";\n");
  File("/tmp/generate_io.txt").writeAsStringSync(sb.toString());
}
