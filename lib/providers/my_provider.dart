import 'package:flutter/material.dart';

class MyProvider with ChangeNotifier {
  // 사용자 정보 저장
  Map<String, dynamic> _userInfo = {
    'name': '', // 이름
    'phone': '', // 전화번호
    'email': '', // 이메일
    'birth': '', // 생년월일
    'gender': '남성', // 성별
  };

  // 사용자 정보 가져오기
  Map<String, dynamic> get userInfo => _userInfo;

  // 사용자 정보 업데이트
  void updateUserInfo(Map<String, dynamic> updatedInfo) {
    _userInfo['name'] = updatedInfo['name'] ?? _userInfo['name'];
    _userInfo['phone'] = updatedInfo['phone'] ?? _userInfo['phone'];
    _userInfo['email'] = updatedInfo['email'] ?? _userInfo['email'];
    _userInfo['birth'] = updatedInfo['birth'] ?? _userInfo['birth'];
    _userInfo['gender'] = updatedInfo['gender'] ?? _userInfo['gender'];

    notifyListeners(); // 변경 사항 알림
  }
}
