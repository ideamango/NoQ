class TokenNotExistsException implements Exception {
  String cause;
  TokenNotExistsException(this.cause);
}
