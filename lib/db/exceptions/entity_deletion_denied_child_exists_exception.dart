class EntityDeletionDeniedChildExistsException implements Exception {
  String cause;
  EntityDeletionDeniedChildExistsException(this.cause);
}
