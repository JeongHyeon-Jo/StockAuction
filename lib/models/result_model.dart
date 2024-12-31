class Result {
  final String? message;
  final bool isSuccess;

  Result.success(this.message) : isSuccess = true;

  Result.failure(this.message) : isSuccess = false;
}

class DataResult<T> extends Result {
  final T? data;

//생성자의 두가지 방법
//변수 받아서 생성자 호출
  DataResult.success(this.data, String? message) : super.success(message);

//변수를 받아서 부모클래스의 파라미터 직접 초기화 후 부모생성자 호출
  DataResult.failure(super.message)
      : data = null,
        super.failure();
}
