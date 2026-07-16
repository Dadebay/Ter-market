// ignore_for_file: avoid_print
//
// Colored console logging used ONLY for the order-placement flow.
//
// Purpose: a customer occasionally hits an "order failed" error (~1 in 5 tries)
// that never reproduces in Postman. These colored logs trace every step of the
// order request/response so the failing case can be spotted in the device
// console (Xcode / `flutter run` / `adb logcat`).
//
// Filter tip: search the console for the tag `[ORDER]` to see only this flow.

class OrderLog {
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';

  static void _line(String color, String tag, String msg) {
    print('$color[ORDER][$tag] $msg$_reset');
  }

  /// A step in the UI flow (cyan).
  static void step(String msg) => _line(_cyan, 'STEP', msg);

  /// General info / values (blue).
  static void info(String msg) => _line(_blue, 'INFO', msg);

  /// Outgoing request payload (magenta).
  static void request(String msg) => _line(_magenta, 'REQ ', msg);

  /// Raw response from the server (green).
  static void response(String msg) => _line(_green, 'RESP', msg);

  /// Success (green, bold-ish).
  static void success(String msg) => _line(_green, ' OK ', msg);

  /// Warning / recoverable issue (yellow).
  static void warn(String msg) => _line(_yellow, 'WARN', msg);

  /// Error — the case we are hunting (red).
  static void error(String msg) => _line(_red, 'FAIL', msg);
}
