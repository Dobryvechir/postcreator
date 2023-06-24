import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:postcreator/utils/model/quick_io_params.dart';
import 'package:postcreator/utils/simple_keys.dart';
import 'simple_io.dart';
import 'persistence_io.dart';

Future<http.Response> ioSendRetryable(String d, String e, String url) async {
  final client = RetryClient(http.Client());
  try {
    String body = "d=$d&e=$e";
    http.Response p = await client.post(Uri.parse(url), body: body);
    return p;
  } finally {
    client.close();
  }
}

Future<String> ioSend(
    String d, String e, String url, Map<String, String>? params) async {
  String fullUrl = url;
  if (params != null) {
    fullUrl = params['urlBefore']! + url + params['urlAfter']!;
  }
  http.Response r = await ioSendRetryable(d, e, fullUrl);
  if (r.statusCode >= 300) {
    throw Exception("Communication error");
  }
  String rep = r.body;
  if (!rep.startsWith("[\"") || !rep.endsWith("\"]")) {
    throw Exception("Communication problem");
  }
  rep = rep.substring(2, rep.length - 2);
  return rep;
}

Future<String> ioHandshakePrimaryWithParams(
    String shake, String hand, Map<String, String> params) async {
  String snc = await getSNC();
  List<String> data = prepareHandshakePrimaryRequest(shake, hand, snc, params);
  String r = await ioSend(data[0], data[1], data[2], params);
  Map<String, String> res = prepareHandshakePrimaryResponse(r, data[3], params);
  if (isValidPersistentParams(res)) {
    storePersistentParams(res);
  }
  return '';
}

Future<String> ioHandshakePrimary(String shake, String hand) async {
  Map<String, String> params = getSystemParams();
  return await ioHandshakePrimaryWithParams(shake, hand, params);
}

Future<String> ioHandshakeSecondaryWithParams(
    Map<String, String> sysParams, Map<String, String> persParams) async {
  List<String> data = prepareHandshakeSecondaryRequest(sysParams, persParams);
  String r = await ioSend(data[0], data[1], data[2], sysParams);
  Map<String, String> res =
      prepareHandshakeSecondaryResponse(r, data[3], persParams);
  if (isValidPersistentParams(res)) {
    storePersistentParams(res);
  }
  return '';
}

Future<String> ioHandshakeSecondary() async {
  Map<String, String> sysParams = getSystemParams();
  Map<String, String> persParams = await getPersistentParams();
  String r = await ioHandshakeSecondaryWithParams(sysParams, persParams);
  return r;
}

Future<String> ioExchangePhaseSend(Map<String, String> params) async {
  QuickIoParams ioParams = await getQuickIOParams();
  String data = ioComposeRequestString(params);
  String d =
      encodeByHashKeyForString(data, ioParams.encodeKey, ioParams.signIn);
  String r = await ioSend(d, ioParams.userToken, ioParams.ioUrl, null);
  return r;
}

Future<Map<String, String>> ioExchangePhaseProcess(String r) async {
  QuickIoParams ioParams = await getQuickIOParams();
  String res = decodeByHashKey(r, ioParams.decodeKey, ioParams.signOut);
  Map<String, String> p = ioDeComposeRequestString(res);
  return p;
}

Future<Map<String, String>> ioExchange(Map<String, String> params) async {
  String r = await ioExchangePhaseSend(params);
  if (r == 'token_expired') {
    ioHandshakeSecondary();
    r = await ioExchangePhaseSend(params);
    if (r == 'token_expired') {
      throw Exception("login");
    }
  }
  return await ioExchangePhaseProcess(r);
}

bool isValidPersistentParams(Map<String, String> pers) {
  if (pers['ioKey'] == null || !checkHashKeyComplete(pers['ioKey']!)) {
    return false;
  }
  if (pers['rfrKey'] == null || !checkHashKeyComplete(pers['rfrKey']!)) {
    return false;
  }
  if (pers['rfrSignOut'] == null || !checkSignId(pers['rfrSignOut']!)) {
    return false;
  }
  if (pers['rfrSignIn'] == null || !checkSignId(pers['rfrSignIn']!)) {
    return false;
  }
  if (pers['ioSignIn'] == null || !checkSignId(pers['ioSignIn']!)) {
    return false;
  }
  if (pers['ioSignOut'] == null || !checkSignId(pers['ioSignOut']!)) {
    return false;
  }
  if (pers['userToken'] == null || !checkUserToken(pers['userToken']!)) {
    return false;
  }
  return true;
}

Future<bool> checkLoginReadiness() async {
  bool ready = true;
  try {
    Map<String, String> pers = await getPersistentParams();
    ready = isValidPersistentParams(pers);
  } on Exception {
    ready = false;
  }
  if (!ready) {
    invalidatePersistentParams();
  }
  return ready;
}
