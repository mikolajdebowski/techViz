class VizTimeoutException implements Exception {
  final String _message;
  VizTimeoutException([this._message]);

  @override
  String toString() {
    if (_message == null) return "Exception";
    return _message;
  }
}