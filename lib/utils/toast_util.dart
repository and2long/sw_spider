import 'package:oktoast/oktoast.dart';

class ToastUtil {
  static show(String msg) {
    showToast(
      msg,
      duration: Duration(seconds: 3),
      position: ToastPosition.center,
    );
  }
}
