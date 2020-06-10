class EntityDoesNotExistsException implements Exception {
  String cause;
  EntityDoesNotExistsException(this.cause);
}
