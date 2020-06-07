class AccessDeniedException implements Exception {
  String cause;
  AccessDeniedException(this.cause);
}
