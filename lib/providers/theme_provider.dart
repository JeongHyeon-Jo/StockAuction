import 'package:auction/config/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkTheme = false;

  // 현재 테마를 반환하는 게터
  ThemeData get currentTheme =>
      _isDarkTheme ? darkThemeData() : lightThemeData();

  // 다크 모드 상태를 반환하는 게터 추가
  bool get isDarkTheme => _isDarkTheme;

  // 테마를 전환하는 함수
  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
  }

  // 다크 모드 테마 설정 함수
  // ThemeData darkThemeData() {
  //   return ThemeData(
  //     brightness: Brightness.dark,
  //     primaryColor: Colors.black,
  //     scaffoldBackgroundColor: Colors.black,
  //     appBarTheme: AppBarTheme(
  //       backgroundColor: Colors.black,
  //       foregroundColor: Colors.white,
  //     ),
  //     iconTheme: IconThemeData(
  //       color: Colors.white,
  //     ),
  //     textTheme: TextTheme(
  //       headlineLarge: TextStyle(color: Colors.white),
  //       bodyLarge: TextStyle(color: Colors.white),
  //       bodyMedium: TextStyle(color: Colors.white60),
  //     ),
  //     bottomNavigationBarTheme: BottomNavigationBarThemeData(
  //       backgroundColor: Colors.black,
  //       selectedItemColor: Colors.red,
  //       unselectedItemColor: Colors.white60,
  //     ),
  //   );
  // }

  // 라이트 모드 테마 설정 함수
//   ThemeData lightThemeData() {
//     return ThemeData(
//       brightness: Brightness.light,
//       primaryColor: Colors.white,
//       scaffoldBackgroundColor: Colors.white,
//       appBarTheme: AppBarTheme(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//       ),
//       iconTheme: IconThemeData(
//         color: Colors.black,
//       ),
//       textTheme: TextTheme(
//         headlineLarge: TextStyle(color: Colors.black),
//         bodyLarge: TextStyle(color: Colors.black),
//         bodyMedium: TextStyle(color: Colors.black87),
//       ),
//       bottomNavigationBarTheme: BottomNavigationBarThemeData(
//         backgroundColor: Colors.white,
//         selectedItemColor: Colors.red,
//         unselectedItemColor: Colors.grey,
//       ),
//     );
//   }
}
