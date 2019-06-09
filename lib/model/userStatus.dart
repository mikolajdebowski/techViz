class UserStatus {
  const UserStatus({this.id, this.description, this.isOnline});
  final String description;
  final String id;
  final bool isOnline;

  @override
  String toString() {
    return description;
  }
}
