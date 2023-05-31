import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;

void printSingleIntArray(List<int>? data, String comment) {
  StringBuffer buffer = StringBuffer(comment);
  if (data == null) {
    buffer.write(" null ");
  } else {
    buffer.write(data);
  }
  print(buffer.toString());
}

void printMultipleIntArrays(List<List<int>?> data, List<String> comments) {
  int n = data.length;
  for (var i = 0; i < n; i++) {
    List<int>? item = data[i];
    String comment = i < comments.length ? comments[i] : " $i";
    printSingleIntArray(item, comment);
  }
}

void printUint8List(Uint8List lst, String message) {
  StringBuffer r = StringBuffer();
  int n = lst.length;
  for (var i = 0; i < n; i++) {
    if (i != 0) {
      r.write(',');
    }
    int k = lst[i];
    r.write(k);
  }
  String v = r.toString();
  print("Uint8List $message [ $v ]");
}

void printStringWithCodes(String data, String message) {
  StringBuffer r = StringBuffer();
  var lst = data.codeUnits;
  int n = lst.length;
  for (var i = 0; i < n; i++) {
    if (i != 0) {
      r.write(',');
    }
    int k = lst[i];
    r.write(k);
  }
  String v = r.toString();
  print("String $message [ $v ]");
}

int evaluateCommaSeparatedList(String data) {
  int n = data.length;
  int count = n == 0 ? 0 : 1;
  List<int> codes = data.codeUnits;
  int comma = ','.codeUnits[0];
  for (int i = 0; i < n; i++) {
    if (codes[i] == comma) {
      count++;
    }
  }
  return count;
}

List<int> readCommaSeparatedIntList(String data) {
  int n = data.length;
  int m = evaluateCommaSeparatedList(data);
  List<int> res = List.filled(m, 0);
  int comma = ','.codeUnits[0];
  List<int> codes = data.codeUnits;
  int v = 0;
  int pos = 0;
  for (int i = 0; i < n; i++) {
    int c = codes[i];
    if (c == comma) {
      res[pos++] = v;
      v = 0;
    } else if (c >= 48 && c <= 57) {
      v = v * 10 + c - 48;
    }
  }
  res[pos] = v;
  return res;
}

List<int> readFileAsIntList(String path, String name) {
  var filePath = p.join(path, name);
  File file = File(filePath);
  String fileContent = file.readAsStringSync();
  return readCommaSeparatedIntList(fileContent);
}

String makeCommaSeparatedIntList(List<int> data) {
  StringBuffer sb = StringBuffer();
  int n = data.length;
  for (int i = 0; i < n; i++) {
    if (i != 0) {
      sb.write(',');
    }
    sb.write(data[i]);
  }
  return sb.toString();
}

void writeFileAsIntList(String path, String name, List<int> data) {
  var filePath = p.join(path, name);
  File file = File(filePath);
  String content = makeCommaSeparatedIntList(data);
  file.writeAsStringSync(content);
}

void writeFileAsString(String path, String name, String data) {
  var filePath = p.join(path, name);
  File file = File(filePath);
  file.writeAsStringSync(data);
}
