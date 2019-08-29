class UserStatus {
  const UserStatus(this.id, this.description, this.isOnline);
  final String description;
  final int id;
  final bool isOnline;

  @override
  String toString() {
    return description;
  }
}
