class QuickIoParams {
  final List<int> encodeKey;
  final List<int> decodeKey;
  final List<int> signIn;
  final List<int> signOut;
  final String userToken;
  final String ioUrl;

  const QuickIoParams({
    required this.encodeKey,
    required this.decodeKey,
    required this.signIn,
    required this.signOut,
    required this.userToken,
    required this.ioUrl,
  });
}
