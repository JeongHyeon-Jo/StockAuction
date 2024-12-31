import 'package:flutter/material.dart';

class TextProvider with ChangeNotifier{
  bool isTextEmpty = true;
  final TextEditingController commentController = TextEditingController();

  TextProvider(){
    commentController.addListener((){
      isTextEmpty = commentController.text.isEmpty ? true : false; // 텍스트 비어있는 지 확인
      notifyListeners();
    });
  }

  @override
  void dispose() {
    commentController.dispose(); // 메모리 누수 방지
    super.dispose();
  }
}