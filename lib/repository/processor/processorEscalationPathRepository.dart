import 'dart:async';
import 'package:techviz/repository/processor/processorLiveTable.dart';
import 'package:techviz/repository/processor/processorRepositoryConfig.dart';
import 'package:techviz/repository/remoteRepository.dart';

class ProcessorEscalationPathRepository extends ProcessorLiveTable<dynamic> implements IRemoteRepository<dynamic> {

  ProcessorEscalationPathRepository(){
    tableID = LiveTableType.TECHVIZ_MOBILE_ESCALATION_PATH.toString();
  }

  @override
  Future fetch() async {
    Completer _completer = Completer<dynamic>();

    super.fetch().then((dynamic livetableResult) async{
      List<String> _columnNames = livetableResult[0] as List<String>;
      List<dynamic> _rows = livetableResult[1] as List<dynamic>;

      List<Map<String, dynamic>> output = <Map<String, dynamic>>[];
      _rows.forEach((dynamic d) {
        dynamic values = d['Values'];

        int _id = int.parse(values[_columnNames.indexOf("IsSubscribed")].toString());
        String _description = values[_columnNames.indexOf("IsSubscribedDescription")] as String;

        Map<String,dynamic> entry = <String,dynamic>{};
        entry['EscalationPathId'] = _id;
        entry['Description'] = _description;

        output.add(entry);
      });
      _completer.complete(output);
    }).catchError((dynamic error){
      _completer.completeError(error);
    });
    return _completer.future;
  }
}