class Log {
  static const isDebug = true;

  ///show debug logs in console
  static void d(String log) {
    if (isDebug) {
      print(log);
    }
  }

  /// show error logs in console
  static void e(String error) {
    if (isDebug) {
      print("Error:: " + error);
    }
  }
}