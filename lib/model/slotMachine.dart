
class SlotMachine{
  final String standID;
  final String machineTypeName;
  final double denom;
  String machineStatusID;
  String machineStatusDescription;

  SlotMachine(this.standID, this.machineTypeName, {this.machineStatusID, this.machineStatusDescription, this.denom : 0.0, });
}