import 'dart:async';

class GlobalSingleTon {
  static final GlobalSingleTon globalSingleTon = GlobalSingleTon._internal();

  factory GlobalSingleTon() {
    return globalSingleTon;
  }
  StreamController profileImageStream = new StreamController.broadcast();

  GlobalSingleTon._internal();

  dynamic loginSubscriptionList;
}
