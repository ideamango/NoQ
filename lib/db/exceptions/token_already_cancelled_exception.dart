class TokenAlreadyCancelledException implements Exception {
  String cause;
  TokenAlreadyCancelledException(this.cause);
}
