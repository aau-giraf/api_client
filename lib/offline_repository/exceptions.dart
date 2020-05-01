/// Overall database exception
class OfflineDatabaseException implements Exception {
  OfflineDatabaseException(this.cause);
  String cause;
}

/// Exception for when model has no offline id
class NoOfflineIdException implements OfflineDatabaseException {
  NoOfflineIdException(this.cause);
  @override
  String cause;
}

/// Exception for row not found in the offline database
class NotFoundException implements OfflineDatabaseException {
  NotFoundException(this.cause);
  @override
  String cause;
}

/// Exception for invalid id
class InvalidIdException implements OfflineDatabaseException {
  InvalidIdException(this.cause);
  @override
  String cause;
}

/// Exception for not implemented in factory
class NotImplementedInFactory implements OfflineDatabaseException {
  NotImplementedInFactory(this.cause);
  @override
  String cause;
}
