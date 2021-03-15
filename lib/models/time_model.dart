import 'dart:async';

import 'package:flutter/material.dart';

/// 游戏中的计时功能

class TimeModel with ChangeNotifier {
  int _tick = 0;

  int get tick => _tick;

  Timer timer;

  void _tickHandler(Timer timer) {
    _tick++;
    notifyListeners();
  }

  void start() {
    _tick = 0;
    timer = Timer.periodic(Duration(seconds: 1), _tickHandler);
    notifyListeners();
  }

  void stop() {
    timer.cancel();
    notifyListeners();
  }

  void reset() {
    _tick = 0;
    timer.cancel();
    notifyListeners();
  }

  void pause() {
    timer.cancel();
    notifyListeners();
  }

  void resume() {
    timer = Timer.periodic(Duration(seconds: 1), _tickHandler);
    notifyListeners();
  }
}
