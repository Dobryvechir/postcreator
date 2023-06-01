import 'dart:io';
import 'package:postcreator/utils/simple_io.dart';

Map<String, String> ioReadMapFromFile(String fileName) {
  List<String> lines = File(fileName).readAsLinesSync();
  Map<String, String> res = {};
  int n = lines.length;
  for (int i = 0; i < n; i++) {
    String line = lines[i];
    int p = line.indexOf('=');
    if (p > 0) {
      String key = line.substring(0, p);
      String value = line.substring(p + 1);
      res[key] = value;
    }
  }
  return res;
}

void ioWriteMapToFile(String fileName, Map<String, String> data) {
  StringBuffer sb = StringBuffer();
  String eol = String.fromCharCode(10);
  data.forEach((key, value) {
    sb.write(key);
    sb.write('=');
    sb.write(value);
    sb.write(eol);
  });
  File(fileName).writeAsStringSync(sb.toString());
}

String compareMapEquality(Map<String, String> src, Map<String, String> dst,
    String srcName, String dstName) {
  StringBuffer sb = StringBuffer();
  String eol = String.fromCharCode(10);
  src.forEach((key, value) {
    String? v = dst[key];
    if (v == null) {
      sb.write(key);
      sb.write(' present in ');
      sb.write(srcName);
      sb.write(' but not in ');
      sb.write(dstName);
      sb.write(eol);
    } else if (value != v) {
      sb.write(key);
      sb.write(' for ');
      sb.write(srcName);
      sb.write(' is ');
      sb.write(value);
      sb.write(' but for ');
      sb.write(dstName);
      sb.write(' is ');
      sb.write(v);
      sb.write(eol);
    }
  });
  dst.forEach((key, value) {
    if (!src.containsKey(key)) {
      sb.write(key);
      sb.write(' present in ');
      sb.write(dstName);
      sb.write(' but not in ');
      sb.write(srcName);
      sb.write(eol);
    }
  });
  return sb.toString();
}

void testMapEquality() {
  String srcFile = '/tmp/mapSrc.txt';
  String dstFile = '/tmp/mapDst.txt';
  String tmpFile = '/tmp/mapMid.txt';
  String errFile = '/tmp/mapErr.txt';
  Map<String, String> src = ioReadMapFromFile(srcFile);
  String dstStr = ioComposeRequestString(src);
  File(tmpFile).writeAsStringSync(dstStr);
  Map<String, String> dst = ioDeComposeRequestString(dstStr);
  ioWriteMapToFile(dstFile, dst);
  String comp = compareMapEquality(src, dst, 'start', 'finish');
  File(errFile).writeAsStringSync(comp);
  if (comp.isEmpty) {
    print('comparison ok');
  } else {
    print('comparison failed, look at mapErr.txt');
  }
}

void main() {
  testMapEquality();
}
