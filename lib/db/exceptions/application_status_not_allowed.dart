class ApplicationStatusNotAllowed implements Exception {
  String cause;
  ApplicationStatusNotAllowed(this.cause);
}
