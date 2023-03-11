
import 'package:flutter/widgets.dart';

class DvdAuth extends ChangeNotifier {
  bool _signedIn = false;

  bool get signedIn => _signedIn;

  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    // Sign out.
    _signedIn = false;
    notifyListeners();
  }

  Future<bool> signIn(String username, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Sign in. Allow any password.
    _signedIn = true;
    notifyListeners();
    return _signedIn;
  }

  @override
  bool operator ==(Object other) =>
      other is DvdAuth && other._signedIn == _signedIn;

  @override
  int get hashCode => _signedIn.hashCode;
}

class DvdAuthScope extends InheritedNotifier<DvdAuth> {
  const DvdAuthScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static DvdAuth of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<DvdAuthScope>()!
      .notifier!;
}
