class UserDoesNotExistsException implements Exception {
  String cause;
  UserDoesNotExistsException(this.cause);
}
