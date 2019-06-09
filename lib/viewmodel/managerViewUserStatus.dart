import 'package:techviz/components/vizSelector.dart';

class ManagerViewUserStatus implements IVizSelectorOption{
  ManagerViewUserStatus(this.id, this.description, this.selected);

  @override
  Object id;

  @override
  bool selected;

  @override
  String description;
}