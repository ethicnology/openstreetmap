class AppError implements Exception {
  const AppError(this.message);

  final String message;

  @override
  String toString() => message;
}
