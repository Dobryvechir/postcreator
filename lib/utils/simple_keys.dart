import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

final _random = Random();
final List<String> _btoaMap = List.filled(64, ' ');
final List<int> _atobMap = List.filled(128, -1);
const int _headSize = 7;
const utf8Dec = Utf8Decoder();
const utf8Enc = Utf8Encoder();

List<int> generateHashKey(int base) {
  List<int> key = List.filled(base << 1, 0);
  Map<int, int> used = {};
  List<int> positions = [];
  for (var i = 0; i < base; i++) {
    int a = _random.nextInt(1000000);
    int b = a % base;
    int c = (a ~/ base) & 255;
    key[i] = b;
    key[i + base] = c;
    if (used.containsKey(b)) {
      positions.add(i);
    } else {
      used[b] = i;
    }
  }
  int n = 0;
  for (var i = 0; i < base; i++) {
    if (!used.containsKey(i)) {
      int pos = positions[n++];
      key[pos] = i;
    }
  }
  return key;
}

List<int> generateId(int size) {
  List<int> key = List.filled(size, 0);
  for (var i = 0; i < size; i++) {
    int a = _random.nextInt(1000000);
    int b = a % 32;
    key[i] = b < 26 ? b + 65 : b - 26 + 48;
  }
  return key;
}

String encodeByHashKeyForString(String data, List<int> key, List<int> id) {
  List<int> codes = data.codeUnits;
  List<int> res = encodeByHashKey(codes, key, id);
  String resData = convertIntListToString(res);
  return resData;
}

Uint8List encodeByHashKeyForUint8List(
    Uint8List data, List<int> key, List<int> id) {
  List<int> codes = utf8Dec.convert(data).codeUnits;
  List<int> res = encodeByHashKey(codes, key, id);
  String resData = convertIntListToString(res);
  return Uint8List.fromList(resData.codeUnits);
}

List<int> encodeByHashKey(List<int> codes, List<int> key, List<int> id) {
  int base = key.length >> 1;
  int algo = findBestAlgo(codes);
  int size = calculateLengthForAlgo(codes, algo);
  int idLen = id.length;
  int minSize = size + idLen + _headSize;
  int padding = calculatePadding(minSize, base);
  int leftPadding = padding == 0 ? 0 : _random.nextInt(padding);
  int rightPadding = padding - leftPadding;
  int totSize = minSize + padding;
  List<int> resp = List.filled(totSize, 0);
  resp[0] = leftPadding & 255;
  resp[1] = leftPadding >> 8;
  resp[2] = rightPadding & 255;
  resp[3] = rightPadding >> 8;
  resp[6] = algo;
  providePadding(resp, _headSize, leftPadding);
  int pos = _headSize + leftPadding;
  provideListCopy(resp, pos, id, idLen);
  pos += idLen;
  provideAlgoData(resp, pos, algo, codes);
  pos += size;
  providePadding(resp, pos, rightPadding);
  int sum = (-calculateSumIntList(resp)) & 0xffff;
  resp[4] = sum & 255;
  resp[5] = sum >> 8;
  List<int> res = encodingByHash(resp, key);
  return res;
}

int calculateSumIntList(List<int> data) {
  int res = 0;
  int n = data.length;
  for (var i = 0; i < n; i++) {
    res += data[i];
    i++;
    res += data[i] << 8;
  }
  return res & 0xffff;
}

List<int> encodingByHash(List<int> src, List<int> key) {
  int base = key.length >> 1;
  int n = src.length;
  List<int> dst = List.filled(n, 0);
  for (int p = 0; p < n; p += base) {
    for (int i = 0; i < base; i++) {
      dst[key[i] + p] = src[i + p] ^ key[i + base];
    }
  }
  return dst;
}

void checkListByteLimited(List<int> data, String place) {
  int n = data.length;
  for (var i = 0; i < n; i++) {
    int v = data[i];
    if (v < 0 || v > 255) {
      throw Exception("byte size exceeded $v at $i in $place");
    }
  }
}

List<String> getBtoaMap() {
  if (_btoaMap[0] == 'a') {
    return _btoaMap;
  }
  for (int i = 0; i < 26; i++) {
    _btoaMap[i] = String.fromCharCode(i + 65);
    _btoaMap[i + 26] = String.fromCharCode(i + 97);
  }
  for (int i = 0; i < 10; i++) {
    _btoaMap[i + 52] = String.fromCharCode(i + 48);
  }
  _btoaMap[62] = '_';
  _btoaMap[63] = '.';
  return _btoaMap;
}

List<int> getAtobMap() {
  if (_atobMap[66] == 1) {
    return _atobMap;
  }
  for (int i = 0; i < 26; i++) {
    _atobMap[i + 65] = i;
    _atobMap[i + 97] = i + 26;
  }
  for (int i = 0; i < 10; i++) {
    _atobMap[i + 48] = i + 52;
  }
  _atobMap['_'.codeUnits[0]] = 62;
  _atobMap['.'.codeUnits[0]] = 63;
  return _atobMap;
}

String convertIntListToString(List<int> src) {
  List<String> conv = getBtoaMap();
  StringBuffer res = StringBuffer();
  int n = src.length;
  int rest = 0;
  int bits = 0;
  for (int i = 0; i < n; i++) {
    rest |= (src[i] << bits);
    res.write(conv[rest & 63]);
    bits += 2;
    rest >>= 6;
    if (bits == 6) {
      res.write(conv[rest]);
      rest = 0;
      bits = 0;
    }
  }
  if (bits > 0) {
    res.write(conv[rest]);
  }
  return res.toString();
}

void provideAlgoData(List<int> dst, int dstPos, int algo, List<int> codes) {
  var n = codes.length;
  if (algo == 8) {
    provideListCopy(dst, dstPos, codes, n);
  } else {
    provideHalfListCopy(dst, dstPos, codes, n);
  }
}

void providePadding(List<int> buf, pos, len) {
  int endPos = pos + len;
  for (var i = pos; i < endPos; i++) {
    buf[i] = _random.nextInt(256);
  }
}

void provideListCopy(List<int> dst, int dstPos, List<int> src, int srcSize) {
  for (var i = 0; i < srcSize; i++) {
    dst[dstPos + i] = src[i] & 255;
  }
}

void provideHalfListCopy(
    List<int> dst, int dstPos, List<int> src, int srcSize) {
  for (var i = 0; i < srcSize; i++) {
    int k = src[i];
    dst[dstPos++] = k & 255;
    dst[dstPos++] = (k >> 8) & 255;
  }
}

int findBestAlgo(List<int> codes) {
  int algo = 8;
  int n = codes.length;
  for (var i = 0; i < n; i++) {
    if (codes[i] > 255) {
      return 16;
    }
  }
  return algo;
}

int calculateLengthForAlgo(List<int> codes, int algo) {
  int n = codes.length;
  if (algo == 16) {
    n = n * 2;
  }
  return n;
}

int calculatePadding(int minSize, int base) {
  int rest = minSize % base;
  return rest == 0 ? 0 : base - rest;
}

List<int> getDecodeKeyByEncodeKey(List<int> key) {
  int n = key.length;
  List<int> res = List.filled(n, 0);
  int m = n ~/ 2;
  for (var i = 0; i < m; i++) {
    res[key[i]] = i;
    res[key[i] + m] = key[i + m];
  }
  return res;
}

List<int> debase64(String data, int unitSize) {
  List<int> conv = getAtobMap();
  int n = data.length;
  int m = n * 3 ~/ 4;
  int extra = m % unitSize;
  if (extra != 0) {
    if (extra > 1) {
      throw Exception('Extra length is too much {extra}');
    }
    m -= extra;
  }
  List<int> res = List.filled(m, 0);
  int rest = 0;
  int bits = 0;
  int pos = 0;
  List<int> codes = data.codeUnits;
  for (var i = 0; i < n; i++) {
    int cd = codes[i];
    if (cd < 32 || cd >= 128 || conv[cd] < 0) {
      throw Exception("unexpected character {cd}");
    }
    rest = (rest << 6) | conv[cd];
    bits += 6;
    if (bits >= 8) {
      bits -= 8;
      res[pos++] = rest >> bits;
      if (pos == m) {
        break;
      }
    }
  }
  return res;
}

Uint8List decodeByHashKeyForUList(Uint8List data, List<int> key, List<int> id) {
  String str = String.fromCharCodes(data);
  String res = decodeByHashKey(str, key, id);
  Uint8List lst = utf8Enc.convert(res);
  return lst;
}

String decodeByHashKey(String data, List<int> key, List<int> id) {
  int unitSize = key.length >> 1;
  List<int> resp = debase64(data, unitSize);
  if (resp.isEmpty) {
    throw Exception('Zero length');
  }
  List<int> res = encodingByHash(resp, key);
  if (res.length < 3 + id.length) {
    throw Exception('Too short message');
  }
  int leftPadding = res[0] | (res[1] << 8);
  int rightPadding = res[2] | (res[3] << 8);
  int sum = calculateSumIntList(res);
  if (sum != 0) {
    throw Exception('sum check error');
  }
  int algo = res[6];
  int posBegin = _headSize + leftPadding;
  int posEnd = res.length - rightPadding;
  if (posEnd < posBegin + id.length) {
    throw Exception('too short data');
  }
  if (!checkExactId(res, posBegin, id)) {
    throw Exception('Bad id');
  }
  String resData = restoreStringByAlgo(res, posBegin + id.length, posEnd, algo);
  return resData;
}

bool checkExactId(List<int> res, int pos, List<int> id) {
  int n = id.length;
  for (var i = 0; i < n; i++) {
    if (res[pos + i] != (id[i] & 255)) {
      return false;
    }
  }
  return true;
}

String restoreStringByAlgo(List<int> src, int posStart, int posEnd, int algo) {
  List<int> res = src;
  if (algo > 8) {
    int n = (posEnd - posStart) >> 1;
    res = List.filled(n, 0);
    for (var i = 0; i < n; i++) {
      int pos = posStart + (i << 1);
      res[i] = src[pos] | (src[pos + 1] << 8);
    }
    posStart = 0;
    posEnd = n;
  }
  return String.fromCharCodes(res, posStart, posEnd);
}
