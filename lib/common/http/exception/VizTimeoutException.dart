class VizTimeoutException implements Exception {
  String cause;
  VizTimeoutException(int timeout) {
    cause = 'Mobile device has not received a response and has time out after ${timeout.toString()} seconds. Please check network details and try again.';
    print(cause);
  }

  @override
  String toString() {
    return cause;
  }
}