import "simple_keys.dart";

String ioEscapeValue(String src) {
  int p1 = src.indexOf('&');
  int p2 = src.indexOf('\\');
  if (p1 < 0) {
    if (p2 < 0) {
      return src;
    }
    p2 = p1;
  }
  if (p2 >= 0 && p2 < p1) {
    p1 = p2;
  }
  StringBuffer sb = StringBuffer();
  int n = src.length;
  if (p1 > 0) {
    sb.write(src.substring(0, p1));
  }
  List<int> codes = src.codeUnits;
  int codeSlash = '\\'.codeUnitAt(0);
  int codeAmpersand = '&'.codeUnitAt(0);
  for (int i = p1; i < n; i++) {
    int c = codes[i];
    if (c == codeSlash) {
      sb.write('\\\\');
    } else if (c == codeAmpersand) {
      sb.write('\\a');
    } else {
      sb.write(String.fromCharCode(c));
    }
  }
  return sb.toString();
}

String ioDeEscapeValue(String src) {
  int p = src.indexOf('\\');
  if (p < 0) {
    return src;
  }
  StringBuffer sb = StringBuffer();
  if (p > 0) {
    sb.write(src.substring(0, p));
  }
  int n = src.length;
  List<int> codes = src.codeUnits;
  int codeSlash = '\\'.codeUnitAt(0);
  int codeA = 'a'.codeUnitAt(0);
  for (int i = p; i < n; i++) {
    int c = codes[i];
    if (c == codeSlash) {
      i++;
      c = i < n ? codes[i] : 0;
      if (c == codeSlash) {
        sb.write('\\');
      } else if (c == codeA) {
        sb.write('&');
      } else {
        throw Exception("incorrect data at $i");
      }
    } else {
      sb.write(String.fromCharCode(c));
    }
  }
  return sb.toString();
}

String ioComposeRequestString(Map<String, String> params) {
  StringBuffer sb = StringBuffer();
  params.forEach((key, value) {
    if (sb.isNotEmpty) {
      sb.write('&');
    }
    if (key.contains('&') || key.contains('=')) {
      throw Exception('wrong key $key');
    }
    sb.write(key);
    sb.write('=');
    String v = ioEscapeValue(value);
    sb.write(v);
  });
  return sb.toString();
}

Map<String, String> ioDeComposeRequestString(String params) {
  Map<String, String> res = {};
  List<String> values = params.split('&');
  int n = values.length;
  for (int i = 0; i < n; i++) {
    String v = values[i];
    int p = v.indexOf('=');
    if (p > 0) {
      String key = v.substring(0, p);
      String value = ioDeEscapeValue(v.substring(p + 1));
      res[key] = value;
    }
  }
  return res;
}

String encodeStringMapComplete(
    Map<String, String> mapSrc, String key, String sign) {
  String src = ioComposeRequestString(mapSrc);
  String data = encodeByHashKeyComplete(src, key, sign);
  return data;
}

Map<String, String> decodeStringMapComplete(
    String src, String key, String sign) {
  String data = encodeByHashKeyComplete(src, key, sign);
  Map<String, String> mapSrc = ioDeComposeRequestString(data);
  return mapSrc;
}

List<String> prepareHandshakePrimaryRequest(
    String shake, String hand, String snc, Map<String, String> params) {
  var keySizeStr = params['keySize'];
  var keySize = keySizeStr == null ? 0 : int.parse(keySizeStr);
  if (keySize < 2) {
    keySize = 16;
  }
  List<int> key = generateHashKey(1 << keySize);
  String keyStr = encodeHashKey(key);
  Map<String, String> p = {
    's': shake,
    'h': hand,
    'k': keyStr,
    'n': snc,
  };
  String data = encodeStringMapComplete(p, params['hdKey']!, params['signIn']!);
  String hp = params['handshakePrimaryUrl'] == null
      ? 'hp'
      : params['handshakePrimaryUrl']!;
  return [data, params['version']!, hp, keyStr];
}

Map<String, String> prepareIoResponse(
    String data, List<int> key, List<int> id) {
  String r = decodeByHashKey(data, key, id);
  Map<String, String> res = ioDeComposeRequestString(r);
  return res;
}

Map<String, String> prepareHandshakePrimaryResponse(
    String data, String keyStr, Map<String, String> params) {
  Map<String, String> res =
      decodeStringMapComplete(data, params['hdKey']!, params['signOut']!);
  res['ioKey'] = keyStr;
  return res;
}

List<String> prepareHandshakeSecondaryRequest(
    Map<String, String> sys, Map<String, String> pers) {
  var keySizeStr = sys['keySize'];
  var keySize = keySizeStr == null ? 0 : int.parse(keySizeStr);
  if (keySize < 2) {
    keySize = 16;
  }
  List<int> key = generateHashKey(1 << keySize);
  String keyStr = encodeHashKey(key);
  Map<String, String> p = {};
  p['k'] = keyStr;
  String data = encodeStringMapComplete(p, pers['rfrKey']!, pers['rfrSignIn']!);
  String hp = sys['handshakeSecondaryUrl'] == null
      ? 'hp'
      : sys['handshakeSecondaryUrl']!;
  return [data, sys['version']!, hp, keyStr];
}

Map<String, String> prepareHandshakeSecondaryResponse(
    String data, String keyStr, Map<String, String> pers) {
  Map<String, String> res =
      decodeStringMapComplete(data, pers['rfrKey']!, pers['rfrSignOut']!);
  res['ioKey'] = keyStr;
  return res;
}

bool checkUserToken(String token) {
  int n = token.length;
  if (n == 0) {
    return false;
  }
  List<int> codes = token.codeUnits;
  for (int i = 0; i < n; i++) {
    int c = codes[i];
    if (!(c >= 48 && c <= 57)) {
      return false;
    }
  }
  return true;
}
