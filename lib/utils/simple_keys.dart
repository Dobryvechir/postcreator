import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import './logging_helper.dart';

final _random = initializeRandom();
final List<String> _btoaMap = List.filled(64, ' ');
final List<String> _btoaMap32 = List.filled(32, ' ');
final List<int> _atobMap = List.filled(128, -1);
final List<int> _atobMap32 = List.filled(128, -1);
const int _headSize = 7;
const utf8Dec = Utf8Decoder();
const utf8Enc = Utf8Encoder();

Random initializeRandom() {
  try {
    return Random.secure();
  } catch (e) {
    // no secure support
  }
  return Random();
}

List<int> generateHashKey(int base) {
  int n = base << 1;
  List<int> key = List.filled(n, base);
  for (var i = base - 1; i >= 0; i--) {
    key[i + base] = _random.nextInt(256);
    int p = _random.nextInt(i + 1);
    int v = key[p] < base ? key[p] : p;
    int u = key[i] < base ? key[i] : i;
    key[p] = u;
    key[i] = v;
  }
  return key;
}

bool checkHashKey(List<int>? key, int base) {
  int n = key != null ? key.length : 0;
  if (n != (base << 1)) {
    return false;
  }
  Map<int, int> pos = {};
  for (var i = 0; i < base; i++) {
    if (!(key![i + base] >= 0 && key[i + base] <= 255)) {
      return false;
    }
    int p = key[i];
    if (!(p >= 0 && p < base) || pos.containsKey(p)) {
      return false;
    }
    pos[p] = 1;
  }
  return true;
}

String generateSignId(int size) {
  StringBuffer res = StringBuffer();
  for (var i = 0; i < size; i++) {
    int a = _random.nextInt(1000000);
    int b = a & 31;
    res.write(String.fromCharCode(b < 26 ? b + 65 : b - 26 + 48));
  }
  return res.toString();
}

bool checkSignId(String signId) {
  List<int> id = signId.codeUnits;
  int n = id.length;
  if (n == 0 || (n & 1) != 0) {
    return false;
  }
  for (var i = 0; i < n; i++) {
    int c = id[i];
    if (!(c >= 65 && c <= 91) && !(c >= 48 && c <= 57)) {
      return false;
    }
  }
  return true;
}

List<int> makeCompactSignId(String data) {
  int n = data.length;
  int size = n * 5;
  int m = (size >> 3) + ((size & 7) != 0 ? 1 : 0);
  List<int> res = List.filled(m, 0);
  List<int> conv = getAtobMap32();
  int rest = 0;
  int bits = 0;
  int pos = 0;
  List<int> codes = data.codeUnits;
  for (var i = 0; i < n; i++) {
    int cd = codes[i];
    if (cd < 32 || cd >= 128 || conv[cd] < 0) {
      throw Exception("unexpected character {cd}");
    }
    rest |= conv[cd] << bits;
    bits += 5;
    if (bits >= 8) {
      bits -= 8;
      res[pos++] = rest & 0xff;
      rest >>= 8;
      if (pos == m) {
        break;
      }
    }
  }
  if (bits >= 0 && pos < m) {
    res[pos] = rest & 0xff;
  }
  return res;
}

String makeExtendedSignId(List<int> src) {
  List<String> conv = getBtoaMap32();
  StringBuffer res = StringBuffer();
  int n = src.length;
  int rest = 0;
  int bits = 0;
  for (int i = 0; i < n; i++) {
    rest |= (src[i] << bits);
    res.write(conv[rest & 31]);
    bits += 3;
    rest >>= 5;
    if (bits >= 5) {
      res.write(conv[rest & 31]);
      rest >>= 5;
      bits -= 5;
    }
  }
  String s = res.toString();
  if ((s.length & 1) != 0) {
    s = s.substring(0, s.length - 1);
  }
  return s;
}

String encodeByHashKeyForString(String data, List<int> key, List<int> id) {
  List<int> codes = data.codeUnits;
  List<int> res = encodeByHashKey(codes, key, id);
  String resData = convertBtoa(res);
  return resData;
}

List<int> directConvertUint8ToIntList(Uint8List src) {
  int n = src.length;
  List<int> res = List.filled(n, 0);
  for (int i = 0; i < n; i++) {
    res[i] = src[i];
  }
  return res;
}

Uint8List encodeByHashKeyForUint8List(
    Uint8List data, List<int> key, List<int> id) {
  List<int> codes = directConvertUint8ToIntList(data);
  List<int> res = encodeByHashKey(codes, key, id);
  String resData = convertBtoa(res);
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
  sum = calculateSumIntList(resp);
  if (sum != 0) {
    throw Exception("Expected zero sum, but it is $sum");
  }
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
  if (_btoaMap[0] == 'A') {
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

List<String> getBtoaMap32() {
  if (_btoaMap32[0] == 'A') {
    return _btoaMap32;
  }
  for (int i = 0; i < 26; i++) {
    _btoaMap32[i] = String.fromCharCode(i + 65);
  }
  for (int i = 0; i < 6; i++) {
    _btoaMap32[i + 26] = String.fromCharCode(i + 48);
  }
  return _btoaMap32;
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

List<int> getAtobMap32() {
  if (_atobMap32[66] == 1) {
    return _atobMap32;
  }
  for (int i = 0; i < 26; i++) {
    _atobMap32[i + 65] = i;
    _atobMap32[i + 97] = i;
  }
  for (int i = 0; i < 10; i++) {
    _atobMap32[i + 48] = (i % 6) + 26;
  }
  return _atobMap32;
}

String convertBtoa(List<int> src) {
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
  int m = n >> 1;
  for (var i = 0; i < m; i++) {
    res[key[i]] = i;
    res[key[i] + m] = key[i + m];
  }
  return res;
}

List<int> convertAtob(String data, int unitSize) {
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
      throw Exception("unexpected character $cd");
    }
    rest |= conv[cd] << bits;
    bits += 6;
    if (bits >= 8) {
      bits -= 8;
      res[pos++] = rest & 0xff;
      rest >>= 8;
      if (pos == m) {
        break;
      }
    }
  }
  return res;
}

int evaluateBytesPerBase(int basis) {
  int base = 1 << basis;
  int n = base * (basis + 8);
  int bytes = (n ~/ 6);
  if ((n % 6) != 0) {
    bytes++;
  }
  return bytes;
}

int evaluateBasisSize(int m) {
  int st = 8;
  int fn = 30;
  int md = 14;
  while (st <= fn) {
    int p = evaluateBytesPerBase(md);
    if (p == m) {
      return md;
    }
    if (p > m) {
      fn = md - 1;
    } else {
      st = md + 1;
    }
    md = (st + fn) >> 1;
  }
  throw Exception("Wrong key size $m");
}

int evaluateBasisByBase(int base) {
  int basis = -1;
  while (base != 0) {
    basis++;
    base >>= 1;
  }
  return basis;
}

List<int> decodeHashKey(String data) {
  List<int> conv = getAtobMap();
  int n = data.length;
  int basis = evaluateBasisSize(n);
  int base = 1 << basis;
  int m = base << 1;
  List<int> res = List.filled(m, 0);
  int rest = 0;
  int bits = 0;
  int pos = 0;
  List<int> codes = data.codeUnits;
  int i = 0;
  int mask = base - 1;
  for (; pos < base; i++) {
    int cd = codes[i];
    if (cd < 32 || cd >= 128 || conv[cd] < 0) {
      throw Exception("unexpected character $cd");
    }
    rest |= conv[cd] << bits;
    bits += 6;
    if (bits >= basis) {
      bits -= basis;
      res[pos++] = rest & mask;
      rest >>= basis;
    }
  }
  for (; i < n; i++) {
    int cd = codes[i];
    if (cd < 32 || cd >= 128 || conv[cd] < 0) {
      throw Exception("unexpected character $cd");
    }
    rest |= conv[cd] << bits;
    bits += 6;
    if (bits >= 8) {
      bits -= 8;
      res[pos++] = rest & 0xff;
      rest >>= 8;
      if (pos == m) {
        break;
      }
    }
  }
  return res;
}

String encodeHashKey(List<int> src) {
  List<String> conv = getBtoaMap();
  StringBuffer res = StringBuffer();
  int n = src.length;
  int base = n >> 1;
  int basis = evaluateBasisByBase(base);
  int rest = 0;
  int bits = 0;
  for (int i = 0; i < n; i++) {
    rest |= (src[i] << bits);
    if (i == base) {
      basis = 8;
    }
    bits += basis;
    while (bits >= 6) {
      res.write(conv[rest & 63]);
      bits -= 6;
      rest >>= 6;
    }
  }
  if (bits > 0) {
    res.write(conv[rest]);
  }
  return res.toString();
}

Uint8List decodeByHashKeyForUList(Uint8List data, List<int> key, List<int> id) {
  String str = String.fromCharCodes(data);
  String res = decodeByHashKey(str, key, id);
  Uint8List lst = utf8Enc.convert(res);
  return lst;
}

String decodeByHashKey(String data, List<int> key, List<int> id) {
  int unitSize = key.length >> 1;
  List<int> resp = convertAtob(data, unitSize);
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
  if (!checkExactSignId(res, posBegin, id)) {
    throw Exception('Bad id');
  }
  String resData = restoreStringByAlgo(res, posBegin + id.length, posEnd, algo);
  return resData;
}

bool checkExactSignId(List<int> res, int pos, List<int> id) {
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
  List<int> origCodes = res.sublist(posStart, posEnd);
  String orig = "";
  try {
    orig = utf8.decode(origCodes);
  } on Exception {
    print("not good utf8");
    orig = String.fromCharCodes(origCodes);
  }
  return orig;
}
