class MaxTokenReachedException implements Exception {
  String cause;
  MaxTokenReachedException(this.cause);
}
