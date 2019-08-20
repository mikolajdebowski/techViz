class VizTimeoutException implements Exception {
  String cause;
  VizTimeoutException(int timeout)
  {
    cause = 'Timeout reached after ${timeout.toString()} seconds';
    print(cause);
  }

  @override
  String toString() {
    return cause;
  }
}