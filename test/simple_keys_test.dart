import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:postcreator/utils/logging_helper.dart';
import 'package:postcreator/utils/simple_keys.dart';

List<int>? simpleKeys;
List<int>? revertedKeys;
List<int>? simpleId;

List<int> readAsIntList(String path, String name) {
  var filePath = p.join(path, name);
  File file = File(filePath);
  String fileContent = file.readAsStringSync();
  return fileContent.codeUnits;
}

void writeAsIntList(String path, String name, List<int> data) {
  var filePath = p.join(path, name);
  File file = File(filePath);
  String content = String.fromCharCodes(data);
  file.writeAsStringSync(content);
}

void readKeyAndId(String path) {
  simpleKeys = readAsIntList(path, 'p_klucz');
  revertedKeys = getDecodeKeyByEncodeKey(simpleKeys!);
  simpleId = readAsIntList(path, 'p_id');
}

void writeKeyAndId(String path) {
  if (simpleKeys != null && simpleId != null) {
    writeAsIntList(path, 'p_klucz', simpleKeys!);
    writeAsIntList(path, 'p_id', simpleId!);
  }
}

void generateKeyAndId(String path, int base, int idSize) {
  simpleKeys = generateHashKey(base);
  String id = generateId(idSize);
  simpleId = makeCompactId(id);
  if (!checkHashKey(simpleKeys, base)) {
    print('wrong key $base');
    throw Exception("wrong key");
  }
  writeKeyAndId(path);
}

void recreateFolder(String src) {
  final present = Directory(src).existsSync();
  if (present) {
    Directory(src).deleteSync(recursive: true);
  }
  Directory(src).createSync(recursive: true);
}

void encodeWholeDirectory(String src, String dst) {
  String srcPath = Directory(src).absolute.path;
  int srcPathLen = srcPath.length;
  List<FileSystemEntity> items =
      Directory(src).listSync(recursive: true, followLinks: false);
  int n = items.length;
  for (var i = 0; i < n; i++) {
    FileSystemEntity entity = items[i];
    String name = entity.absolute.path.substring(srcPathLen);
    String dstName = dst + name;
    if (entity.statSync().type == FileSystemEntityType.directory) {
      Directory(dstName).createSync(recursive: true);
    } else {
      copyEncodedFile(entity, dstName);
    }
  }
}

void decodeWholeDirectory(String src, String dst) {
  String srcPath = Directory(src).absolute.path;
  int srcPathLen = srcPath.length;
  List<FileSystemEntity> items =
      Directory(src).listSync(recursive: true, followLinks: false);
  int n = items.length;
  for (var i = 0; i < n; i++) {
    FileSystemEntity entity = items[i];
    String name = entity.absolute.path.substring(srcPathLen);
    String dstName = dst + name;
    if (entity.statSync().type == FileSystemEntityType.directory) {
      Directory(dstName).createSync(recursive: true);
    } else {
      copyDecodedFile(entity, dstName);
    }
  }
}

Uint8List convertWithEncoding(Uint8List buf) {
  buf = encodeByHashKeyForUint8List(buf, simpleKeys!, simpleId!);
  return buf;
}

Uint8List convertWithDecoding(Uint8List buf) {
  buf = decodeByHashKeyForUList(buf, revertedKeys!, simpleId!);
  return buf;
}

void copyEncodedFile(FileSystemEntity entity, String dst) {
  Uint8List bytes = File(entity.path).readAsBytesSync();
  var buf = convertWithEncoding(bytes);
  File(dst).writeAsBytesSync(buf);
}

void copyDecodedFile(FileSystemEntity entity, String dst) {
  Uint8List bytes = File(entity.path).readAsBytesSync();
  var buf = convertWithDecoding(bytes);
  File(dst).writeAsBytesSync(buf);
}

void compareFoldersWithOutput(String src, String dst) {
  String srcPath = Directory(src).absolute.path;
  int srcPathLen = srcPath.length;
  String dstPath = Directory(dst).absolute.path;
  int dstPathLen = dstPath.length;
  List<FileSystemEntity> srcItems =
      Directory(src).listSync(recursive: true, followLinks: false);
  List<FileSystemEntity> dstItems =
      Directory(dst).listSync(recursive: true, followLinks: false);

  int nSrc = srcItems.length;
  int nDst = dstItems.length;
  Map<String, FileSystemEntity> srcMap = {};
  Map<String, FileSystemEntity> dstMap = {};
  for (var i = 0; i < nSrc; i++) {
    FileSystemEntity entity = srcItems[i];
    String name = entity.absolute.path.substring(srcPathLen);
    srcMap[name] = entity;
  }
  for (var i = 0; i < nDst; i++) {
    FileSystemEntity entity = dstItems[i];
    String name = entity.absolute.path.substring(dstPathLen);
    dstMap[name] = entity;
  }
  bool c1 = checkNonExisting(
      "present in $src but not present in $dst", srcMap, dstMap);
  bool c2 = checkNonExisting(
      "present in $dst but not present in $src", dstMap, srcMap);
  bool c3 = checkDeep(srcMap, dstMap);
  if (c1 && c2 && c3) {
    print('Completed comparison ok');
  } else {
    print('Completed comparison failed');
  }
}

bool checkNonExisting(String message, Map<String, FileSystemEntity> src,
    Map<String, FileSystemEntity> dst) {
  bool res = true;
  for (var k in src.keys) {
    if (dst[k] == null) {
      res = false;
      print(message + " $k");
    }
  }
  return res;
}

bool checkDeep(
    Map<String, FileSystemEntity> src, Map<String, FileSystemEntity> dst) {
  var res = true;
  for (var k in src.keys) {
    var s1 = src[k];
    var s2 = dst[k];
    if (s2 == null || s2.statSync().type == FileSystemEntityType.directory) {
      continue;
    }
    var buf1 = File(s1!.path).readAsBytesSync();
    var buf2 = File(s2.path).readAsBytesSync();
    if (!deepBufComparison(buf1, buf2)) {
      print("Not equal in $k");
      res = false;
    }
  }
  return res;
}

bool deepBufComparison(Uint8List? buf1, Uint8List? buf2) {
  if (buf1 == null) {
    return buf2 == null;
  }
  if (buf2 == null) {
    return false;
  }
  int n = buf1.length;
  if (n != buf2.length) {
    return false;
  }
  for (var i = 0; i < n; i++) {
    if (buf1[i] != buf2[i]) {
      return false;
    }
  }
  return true;
}

void compareCheckKeys(String name, List<int>? src1, List<int>? src2) {
  if (src1 == null) {
    if (src2 == null) {
      print('ok (null) in ' + name);
    } else {
      print('diff src1 null but src2 not in ' + name);
    }
    return;
  }
  if (src2 == null) {
    print('diff src2 null but src1 not in ' + name);
    return;
  }
  int n1 = src1.length;
  int n2 = src2.length;
  if (n1 != n2) {
    print('diff lengths in ' + name + " $n1 and $n2");
    return;
  }
  for (var i = 0; i < n1; i++) {
    int c1 = src1[i];
    int c2 = src2[i];
    if (c1 != c2) {
      print("dif at position $i ($c1 and $c2) in $name");
      return;
    }
  }
  print("ok in $name");
}

void reloadKeysWithChecking() {
  List<int>? simpleKeysOrig = simpleKeys;
  List<int>? simpleIdOrig = simpleId;
  simpleKeys = null;
  simpleId = null;
  readKeyAndId('/tmp');
  compareCheckKeys('simpleKeys', simpleKeysOrig, simpleKeys);
  compareCheckKeys('simpleId', simpleIdOrig, simpleId);
}

void testDirectoryEncodingDecoding() {
  int base = 1 << 14;
  int idSize = 20;
  print("Start generating key($base) and id($idSize)");
  generateKeyAndId('/tmp', base, idSize);
  print('start recreating folder tmp/enc');
  recreateFolder('/tmp/enc');
  print('start encoding to tmp/enc');
  encodeWholeDirectory('/temp', '/tmp/enc');
  reloadKeysWithChecking();
  print('start recreating folder tmp/dec');
  recreateFolder('/tmp/dec');
  print('start decoding');
  decodeWholeDirectory('/tmp/enc', '/tmp/dec');
  print('start comparison');
  compareFoldersWithOutput('/temp', '/tmp/dec');
}

List<int> convertBtoaAtob(List<int> data) {
  String resData = convertBtoa(data);
  printStringWithCodes(resData, "resdata");
  Uint8List res = Uint8List.fromList(resData.codeUnits);
  printUint8List(res, "res");
  String str = String.fromCharCodes(res);
  printStringWithCodes(str, "str");
  List<int> resp = convertAtob(str, 4);
  return resp;
}

String analyzeListEquals(List<int>? src, List<int>? dst) {
  if (src == null) {
    return dst == null ? "ok" : "fail src is null, but dst is not ";
  }
  if (dst == null) {
    return "fail dst is null but src is not";
  }
  int n = src.length;
  if (dst.length != n) {
    return "fail src length is $n but dst length is ${dst.length}";
  }
  for (var i = 0; i < n; i++) {
    int s = src[i];
    int d = dst[i];
    if (s != d) {
      return "fail different at $i - $s and $d";
    }
  }
  return "ok";
}

void testBtoaAtob() {
  List<int> orig = [0, 1, 2, 3, 75, 150, 255, 160];
  List<int> res = convertBtoaAtob(orig);
  String s = analyzeListEquals(orig, res);
  print("Comparison result: $s");
  printMultipleIntArrays([orig, res], ["orig", "res"]);
}

void testGenerateCheckCompactExtendedId() {
  int lim = 20000;
  int order = 0;
  for (var size = 2; size < lim; size += 2) {
    String id = generateId(size);
    bool checked = checkId(id);
    List<int> compact = makeCompactId(id);
    String extended = makeExtendedId(compact);
    if (!(checked && id == extended)) {
      order++;
      print("$size id fails checked=$checked id=$id extended=$extended");
    }
  }
  if (order == 0) {
    print("id ok 2..$lim");
  } else {
    print("id failed $order times");
  }
}

void testGenerateEncodeDecodeHashKey() {
  for (int basis = 8; basis < 24; basis++) {
    int base = 1 << basis;
    List<int> key = generateHashKey(base);
    print("started base=$base basis=$basis key=${key.length}");
    bool checked = checkHashKey(key, base);
    if (!checked) {
      print("$basis key failed at check ${key.length}");
    } else {
      String encoded = encodeHashKey(key);
      List<int> decoded = decodeHashKey(encoded);
      String s = analyzeListEquals(key, decoded);
      print("$basis comparison result: $s");
    }
  }
}

void main() {
  // testBtoaAtob();
  // testGenerateCheckCompactExtendedId();
  testGenerateEncodeDecodeHashKey();
  testDirectoryEncodingDecoding();
}
