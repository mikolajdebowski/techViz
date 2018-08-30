import 'dart:async';

import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';
import 'dart:convert';

class ProcessorRepositoryConfig {
  static final ProcessorRepositoryConfig _singleton = new ProcessorRepositoryConfig._internal();

  factory ProcessorRepositoryConfig() {
    return _singleton;
  }
  ProcessorRepositoryConfig._internal();


  String DocumentID;
  List<LiveTable> LiveTables;

  Future<void> Setup(SessionClient client) async{
    String documentListStr = await client.post("visualDocIndex/advancedSearch.json", advancedSearchXML);
    List<dynamic> documentList = json.decode(documentListStr);
    Map<String,dynamic> documentMobile = null;

    for(Map<String,dynamic> doc  in documentList){
      String tag = doc['Tag'];
      if(tag.contains('TechViz2')){
        documentMobile = doc;
        break;
      }
    }

    if(documentMobile == null){
      throw Exception('No mobile document');
    }


    DocumentID = documentMobile['ID'] as String;

    String documentStr = await client.get("visualDoc/${DocumentID}.json?&itemCount=200");
    Map<String,dynamic> documentJson = json.decode(documentStr);
    List<dynamic> liveTableslist = documentJson['liveDataDefinition']['liveTables'];

    LiveTables = List<LiveTable>();
    List<LiveTableType> listTableTags = List<LiveTableType>();
    listTableTags.add(LiveTableType.TECHVIZ_MOBILE_TASK);
    listTableTags.add(LiveTableType.TECHVIZ_MOBILE_TASK_STATUS);
    listTableTags.add(LiveTableType.TECHVIZ_MOBILE_TASK_TYPE);
    listTableTags.add(LiveTableType.TECHVIZ_MOBILE_ROLE);
    listTableTags.add(LiveTableType.TECHVIZ_MOBILE_USER_ROLE);
    listTableTags.add(LiveTableType.TECHVIZ_MOBILE_USER);
    listTableTags.add(LiveTableType.TECHVIZ_MOBILE_USER_STATUS);

    for(Map<String,dynamic> liveTable in liveTableslist){
      String liveTableTag = liveTable['tags'];
      if(liveTableTag.length==0)
        continue;

      liveTableTag = 'LiveTableType.$liveTableTag';

      LiveTableType liveTableTagTyped = LiveTableType.values.firstWhere((e)=> e.toString() == liveTableTag);

      if(listTableTags.contains(liveTableTagTyped)){
        LiveTables.add(LiveTable(liveTable['ID'].toString(), liveTableTag, []));
      };
    }

    print('done setup');

  }

  LiveTable GetLiveTable(String Tag){
    assert(DocumentID!=null);
    assert(LiveTables!=null);

    var lt = LiveTables.where((LiveTable lt) => lt.Tags == Tag);
    if(lt==null || lt.length==0){
      throw Exception('No livetable for ${Tag}');
    }
    return lt.first;
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
  TECHVIZ_MOBILE_ROLE,
  TECHVIZ_MOBILE_USER_ROLE,
  TECHVIZ_MOBILE_USER,
  TECHVIZ_MOBILE_USER_STATUS
}

class LiveTable{
  final String ID;
  final String Tags;
  final List<String> Columns;

  LiveTable(/*this.Type, */this.ID, this.Tags, this.Columns);
}