class Role {
  final int id;
  final String description;

  final bool isAttendant;
  final bool isManager;
  final bool isSupervisor;
  final bool isTechManager;
  final bool isTechnician;
  final bool isTechSupervisor;

  const Role({this.id, this.description, this.isAttendant, this.isManager, this.isSupervisor, this.isTechManager, this.isTechnician, this.isTechSupervisor});

}