// 숫자를 가격 형식으로 변환하는 함수
import 'package:intl/intl.dart';

String formatPrice(String value) {
  if (value.isEmpty) return '';
  // 숫자만 남기기 위해 정규 표현식을 사용
  final newValue = value.replaceAll(RegExp(r'[^0-9]'), '');

  // 숫자를 3자리마다 콤마(,) 추가
  final formatter = NumberFormat('#,###');
  return formatter.format(int.parse(newValue));
}

int parseIntPrice(String value) {
  if (value.isEmpty) return 0;
  // 숫자가 아닌 모든 문자 제거
  final numericString = value.replaceAll(RegExp(r'[^0-9]'), '');

  // 빈 문자열이 되면 0 반환
  if (numericString.isEmpty) return 0;

  // 문자열을 정수로 변환
  return int.parse(numericString);
}