class Role {
  final int id;
  final String description;

  final bool isAttendant;
  final bool isManager;
  final bool isSupervisor;
  final bool isTechManager;
  final bool isTechnician;
  final bool isTechSupervisor;

  const Role({this.id, this.description, this.isAttendant = false, this.isManager = false, this.isSupervisor = false, this.isTechManager = false, this.isTechnician = false, this.isTechSupervisor = false});

}