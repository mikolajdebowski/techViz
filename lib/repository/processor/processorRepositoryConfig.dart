import 'dart:async';
import 'dart:convert';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';


class ProcessorRepositoryConfig {
  static final ProcessorRepositoryConfig _singleton = new ProcessorRepositoryConfig._internal();
  String _documentID;
  List<LiveTable> _liveTables;

  String get DocumentID{
    return _documentID;
  }


  factory ProcessorRepositoryConfig() {
    return _singleton;
  }
  ProcessorRepositoryConfig._internal();


  Future<void> Setup(SessionClient client) async{
    String documentListStr = await client.post("visualDocIndex/advancedSearch.json", advancedSearchXML);
    List<dynamic> documentList = json.decode(documentListStr);
    dynamic docsWhere = documentList.where((dynamic doc)=> doc['Tag'] == 'TechVizMobile');

    if(docsWhere==null || docsWhere.length==0){
      throw Exception('No mobile document');
    }

    Map<String,dynamic> documentMobile = docsWhere.first;

    _documentID = documentMobile['ID'] as String;

    String documentStr = await client.get("visualDoc/${_documentID}.json?&itemCount=200");
    dynamic documentJson = json.decode(documentStr);
    List<dynamic> liveTableslist = documentJson['liveDataDefinition']['liveTables'] as List<dynamic>;

    //filter only livetables where tags property length is > 0
    liveTableslist = liveTableslist.where((dynamic lt)=> (lt['tags'] as String).length>0).toList();

    _liveTables = List<LiveTable>();
    for(dynamic liveTable in liveTableslist){
      String _liveTableTag = liveTable['tags'] as String;
      _liveTables.add(LiveTable(liveTable['ID'].toString(), _liveTableTag));
    }

    print('Setup is done');

  }

  LiveTable GetLiveTable(String tagID){
    assert(_documentID!=null);
    assert(_liveTables!=null);

    tagID = tagID.replaceAll('LiveTableType.', '');

    LiveTable lt = _liveTables.firstWhere((LiveTable lt) => lt.tags == tagID, orElse: () => null);
    if(lt==null){
      throw Exception('No livetable for TAG ${tagID}');
    }
    return lt;
  }

  String GetURL(String livetableTagID){
    assert(_documentID!=null);
    assert(_liveTables!=null);

    LiveTable lt = GetLiveTable(livetableTagID);

    return 'live/${_documentID}/${lt.id}/select.json';
  }


  String advancedSearchXML = '''<SearchCriteria>
  <LeftHandSide>
    <SearchPredicate>
      <Name>ShowDeleted</Name>
      <Op>EQ</Op>
      <Value>false</Value>
    </SearchPredicate>
  </LeftHandSide>
  <LogicalOperator>AND</LogicalOperator>
  <RightHandSide>
    <SearchCriteria>
      <LeftHandSide>
        <SearchCriteria>
          <LeftHandSide>
            <SearchPredicate>
              <Name>VisualDocumentType</Name>
              <Op>EQ</Op>
              <Value>Standard</Value>
            </SearchPredicate>
          </LeftHandSide>
          <LogicalOperator>OR</LogicalOperator>
          <RightHandSide>
            <SearchPredicate>
              <Name>VisualDocumentType</Name>
              <Op>EQ</Op>
              <Value>NonVisual</Value>
            </SearchPredicate>
          </RightHandSide>
        </SearchCriteria>
      </LeftHandSide>
      <LogicalOperator>AND</LogicalOperator>
      <RightHandSide>
        <SearchCriteria>
          <LeftHandSide>
            <SearchPredicate>
              <Name>ExcludeSiblings</Name>
              <Op>EQ</Op>
              <Value>true</Value>
            </SearchPredicate>
          </LeftHandSide>
          <LogicalOperator>AND</LogicalOperator>
          <RightHandSide>
            <SearchCriteria>
              <LeftHandSide>
                <SearchCriteria>
                  <LeftHandSide>
                    <SearchPredicate>
                      <Name>VisualdocStatus</Name>
                      <Op>EQ</Op>
                      <Value>ReRenderable</Value>
                    </SearchPredicate>
                  </LeftHandSide>
                  <LogicalOperator>OR</LogicalOperator>
                  <RightHandSide>
                    <SearchCriteria>
                      <LeftHandSide>
                        <SearchPredicate>
                          <Name>VisualdocStatus</Name>
                          <Op>EQ</Op>
                          <Value>Previewable</Value>
                        </SearchPredicate>
                      </LeftHandSide>
                      <LogicalOperator>OR</LogicalOperator>
                      <RightHandSide>
                        <SearchPredicate>
                          <Name>VisualdocStatus</Name>
                          <Op>EQ</Op>
                          <Value>NotModifiable</Value>
                        </SearchPredicate>
                      </RightHandSide>
                    </SearchCriteria>
                  </RightHandSide>
                </SearchCriteria>
              </LeftHandSide>
              <LogicalOperator>OR</LogicalOperator>
              <RightHandSide>
                <SearchCriteria>
                  <LeftHandSide>
                    <SearchPredicate>
                      <Name>VisualdocStatus</Name>
                      <Op>EQ</Op>
                      <Value>UserModifiable</Value>
                    </SearchPredicate>
                  </LeftHandSide>
                  <LogicalOperator>AND</LogicalOperator>
                  <RightHandSide>
                    <SearchPredicate>
                      <Name>Group</Name>
                      <Op>EQ</Op>
                      <Value>Form</Value>
                    </SearchPredicate>
                  </RightHandSide>
                </SearchCriteria>
              </RightHandSide>
            </SearchCriteria>
          </RightHandSide>
        </SearchCriteria>
      </RightHandSide>
    </SearchCriteria>
  </RightHandSide>
</SearchCriteria>''';

}

enum LiveTableType{
  TECHVIZ_MOBILE_TASK,
  TECHVIZ_MOBILE_TASK_STATUS,
  TECHVIZ_MOBILE_TASK_TYPE,
  TECHVIZ_MOBILE_TASK_URGENCY,
  TECHVIZ_MOBILE_ROLE,
  TECHVIZ_MOBILE_USER_ROLE,
  TECHVIZ_MOBILE_USER,
  TECHVIZ_MOBILE_USER_STATUS,
  TECHVIZ_MOBILE_RESERVATION_TIME,
  TECHVIZ_MOBILE_SECTION,
  TECHVIZ_MOBILE_USER_SECTION,
  TECHVIZ_MOBILE_SLOTS,
  TECHVIZ_MOBILE_USER_GENERAL_INFO,
  TECHVIZ_MOBILE_ESCALATION_PATH,


  //stats
  TECHVIZ_MOBILE_USER_TODAY_STATS,
  TECHVIZ_MOBILE_TEAM_TODAY_STATS,
  TECHVIZ_MOBILE_USER_SKILLS,

  //summary
  TECHVIZ_MOBILE_TASK_SUMMARY
}

class LiveTable{
  final String id;
  final String tags;
  final bool initialSync;

  LiveTable(this.id, this.tags, {this.initialSync = true});
}