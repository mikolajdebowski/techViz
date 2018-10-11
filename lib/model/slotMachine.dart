
class SlotMachine{
  final String standID;
  final String machineTypeName;
  final String machineStatusID;
  final String reservationStatusID;
  final String reservationTime;
  final double denom;

  SlotMachine(this.standID, this.machineTypeName, {this.machineStatusID, this.reservationStatusID, this.reservationTime, this.denom});
}