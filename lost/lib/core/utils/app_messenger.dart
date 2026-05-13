import 'package:flutter/material.dart';

class AppMessenger {
  AppMessenger._();

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSuccess(String message) {
    _show(message, Colors.green);
  }

  static void showError([String message = 'Something went wrong. Please try again.']) {
    _show(message, Colors.red);
  }

  static void showInfo(String message) {
    _show(message, Colors.blueGrey);
  }

  static void showSnackBar(SnackBar snackBar) {
    final state = messengerKey.currentState;
    if (state == null) return;
    state.removeCurrentSnackBar();
    state.showSnackBar(snackBar);
  }

  static void _show(String message, Color backgroundColor) {
    showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
