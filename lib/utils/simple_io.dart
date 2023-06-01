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
