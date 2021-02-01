class TokenAlreadyExistsException implements Exception {
  String cause;
  TokenAlreadyExistsException(this.cause);
}
