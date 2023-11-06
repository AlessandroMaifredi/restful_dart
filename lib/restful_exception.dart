class RestfulException implements Exception {
  int code;

  String message;

  RestfulException({required this.code, required this.message});

  @override
  String toString() {
    return message;
  }
}
