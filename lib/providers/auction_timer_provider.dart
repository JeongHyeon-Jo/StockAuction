import 'dart:async';
import 'package:flutter/cupertino.dart';

class AuctionTimerProvider with ChangeNotifier{
  late int remainingTime;
  late Timer _timer;

  AuctionTimerProvider(this.remainingTime){
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        remainingTime--;
        notifyListeners();
      } else {
        _timer.cancel();
      }
    });
  }

  String get formattedTime {
    final days = remainingTime ~/ (24 * 3600);
    final hours = (remainingTime % (24 * 3600)) ~/ 3600;
    final minutes = (remainingTime % 3600) ~/ 60;
    final seconds = remainingTime % 60;

    final List<String> parts = [];

    if (days > 0) {
      parts.add('${days}일');
    }
    if (hours > 0) {
      parts.add('${hours.toString().padLeft(2, '0')}시');
    }
    if (minutes > 0) {
      parts.add('${minutes.toString().padLeft(2, '0')}분');
    }
    if (seconds > 0) {
      parts.add('${seconds.toString().padLeft(2, '0')}초');
    }

    return parts.isEmpty ? '0초' : parts.join(' ');
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}