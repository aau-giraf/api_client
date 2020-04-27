/// Exception for row not found in the offline database
class NotFound implements Exception {
  /// constructor
  NotFound(this.cause);

  /// cause
  String cause;
}
