import 'dart:typed_data';

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
