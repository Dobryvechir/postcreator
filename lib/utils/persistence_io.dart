import "dart:io";
import "package:path_provider/path_provider.dart";
import 'package:path/path.dart' as p;

import "../custom/custom_params.dart" as cust;
import "simple_io.dart";
import "simple_keys.dart";
import "model/quick_io_params.dart";

Map<String, String>? systemParams;
Map<String, String>? persistentParams;
QuickIoParams? quickIoParams;
String? documentsDirectory;

Map<String, String> getSystemParams() {
  systemParams ??= {
    'exchangeUrl': cust.exchangeUrl,
    'handshakePrimaryUrl': cust.handshakePrimaryUrl,
    'handshakeSecondaryUrl': cust.handshakeSecondaryUrl,
    'hdKey': cust.hdKey,
    'keySize': cust.keySize,
    'signIn': cust.signIn,
    'signOut': cust.signOut,
    'stKey': cust.stKey,
    'stSign': cust.stSign,
    'urlBefore': cust.urlBefore,
    'urlAfter': cust.urlAfter,
    'version': cust.version,
  };
  return systemParams!;
}

Future<Map<String, String>> getPersistentParams() async {
  if (persistentParams != null) {
    return persistentParams!;
  }
  String p = await getStoreFilePath('common.bin');
  String d = await File(p).readAsString();
  Map<String, String> sys = getSystemParams();
  persistentParams = decodeStringMapComplete(d, sys['stKey']!, sys['stSign']!);
  return persistentParams!;
}

Future<String> getStoreFilePath(String name) async {
  String path = await getStoreWholePath();
  String fullPath = p.join(path, name);
  return fullPath;
}

Future<String> getStoreWholePath() async {
  if (documentsDirectory == null) {
    final directory = await getApplicationDocumentsDirectory();
    documentsDirectory = directory.path;
  }
  return documentsDirectory!;
}

void storePersistentParams(Map<String, String> params) async {
  persistentParams = params;
  updateQuickIOParams();
  Map<String, String> sys = getSystemParams();
  String d = encodeStringMapComplete(params, sys['stKey']!, sys['stSign']!);
  String p = await getStoreFilePath('common.bin');
  await File(p).writeAsString(d);
}

Future<QuickIoParams> getQuickIOParams() async {
  if (quickIoParams != null) {
    return quickIoParams!;
  }
  await updateQuickIOParams();
  if (quickIoParams != null) {
    return quickIoParams!;
  }
  throw Exception("IO is not ready");
}

Future<void> updateQuickIOParams() async {
  Map<String, String> pers = await getPersistentParams();
  Map<String, String> sys = getSystemParams();
  List<int> encodeKey = decodeHashKey(pers['ioKey']!);
  List<int> decodeKey = getDecodeKeyByEncodeKey(encodeKey);
  List<int> signIn = makeCompactSignId(pers['ioSignIn']!);
  List<int> signOut = makeCompactSignId(pers['ioSignOut']!);
  String userToken = pers['userToken']!;
  String ioUrl = sys['urlBefore']! + sys['exchangeUrl']! + sys['urlAfter']!;
  quickIoParams = QuickIoParams(
    encodeKey: encodeKey,
    decodeKey: decodeKey,
    signIn: signIn,
    signOut: signOut,
    userToken: userToken,
    ioUrl: ioUrl,
  );
}

void invalidatePersistentParams() {
  persistentParams = null;
}

Future<String> getSNC() async {
  String p = await getStoreFilePath('snc.txt');
  try {
    String r = File(p).readAsStringSync();
    if (r.length > 10 && checkSignId(r)) {
      return r;
    }
  } on Exception {
    // this can happen if it is for the first time
  }
  String sn = generateSignId(cust.sncSize);
  File(p).writeAsStringSync(sn);
  return sn;
}
