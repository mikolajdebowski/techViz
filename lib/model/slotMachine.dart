
class SlotMachine{
  final String standID;
  double denom;
  String machineTypeName;
  String machineStatusID;
  String machineStatusDescription;
  DateTime updatedAt;
  String playerID;
  String reservationTime;
  bool dirty;

  SlotMachine({this.standID, this.machineTypeName, this.machineStatusID, this.machineStatusDescription, this.denom = 0.0, this.updatedAt,  this.playerID,  this.reservationTime, this.dirty = false});
}