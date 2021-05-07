class CantRemoveAdminWithOneAdminException implements Exception {
  String cause;
  CantRemoveAdminWithOneAdminException(this.cause);
}
