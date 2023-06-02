import 'dart:io';
import 'package:postcreator/utils/simple_io.dart';
import 'package:postcreator/utils/simple_keys.dart';

void main() {
   StringBuffer sb = StringBuffer();
   String id1 = generateSignId(20);
   String id2 = generateSignId(20);
   String key = encodeHashKey(generateHashKey(1<<16));
   sb.write("String signIn=\"$id1\";\n");
   sb.write("String signOut=\"$id2\";\n");
   sb.write("String hdKey=\"$key\";\n");
   File("/tmp/generate_io.txt").writeAsStringSync(sb.toString());
}