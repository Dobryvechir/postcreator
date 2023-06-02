import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'simple_io.dart';

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
    String d, String e, String url, Map<String, String> params) async {
  String fullUrl = params['urlBefore']! + url + params['urlAfter']!;
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

Future<Map<String, String>> ioHandshakePrimary(
    String shake, String hand, Map<String, String> params) async {
  List<String> data = prepareHandshakePrimaryRequest(shake, hand, params);
  String r = await ioSend(data[0], data[1], data[2], params);
  Map<String, String> res = prepareHandshakePrimaryResponse(r, data[3], params);
  return res;
}
