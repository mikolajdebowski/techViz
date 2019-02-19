
class SlotMachine{
  final String standID;
  double denom;
  String machineTypeName;
  String machineStatusID;
  String machineStatusDescription;

  SlotMachine(this.standID, {this.machineTypeName, this.machineStatusID, this.machineStatusDescription, this.denom : 0.0, });
}