import 'dart:async';
import 'package:techviz/repository/local/escalationPathTable.dart';
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
      var _columnNames = livetableResult[0] as List<String>;
      var _rows = livetableResult[1] as List<dynamic>;

      List<Map<String, dynamic>> toInsert = List<Map<String, dynamic>>();
      _rows.forEach((dynamic d) {
        dynamic values = d['Values'];

        int _id = int.parse(values[_columnNames.indexOf("IsSubscribed")].toString());
        String _description = values[_columnNames.indexOf("IsSubscribedDescription")] as String;
        String _lookupName = values[_columnNames.indexOf("LookupName")] as String;

        Map<String,dynamic> entry = Map<String,dynamic>();
        entry['EscalationPathId'] = _id;
        entry['Description'] = _description;
        entry['LookupName'] = _lookupName;

        toInsert.add(entry);
      });

      int inserted = await EscalationPathTable().insert(toInsert);

      _completer.complete(inserted);
    }).catchError((dynamic error){
      _completer.completeError(error);
    });

    return _completer.future;
  }

}