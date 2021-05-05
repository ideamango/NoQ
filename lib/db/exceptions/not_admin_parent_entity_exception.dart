class NotAdminParentEntityException implements Exception {
  String cause;
  NotAdminParentEntityException(this.cause);
}
