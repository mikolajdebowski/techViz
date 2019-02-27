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
    dynamic documentList = json.decode(documentListStr);
    Map<String,dynamic> documentMobile = null;

    for(Map<String,dynamic> doc  in documentList){
      String tag = doc['Tag'] as String;
      if(tag.contains('TechVizMobile')){
        documentMobile = doc;
        break;
      }
    }

    if(documentMobile == null){
      throw Exception('No mobile document');
    }

    DocumentID = documentMobile['ID'] as String;

    String documentStr = await client.get("visualDoc/${DocumentID}.json?&itemCount=200");
    dynamic documentJson = json.decode(documentStr);
    List<dynamic> liveTableslist = documentJson['liveDataDefinition']['liveTables'] as List<dynamic>;

    List<LiveTableType> mandatorySyncTablesTags = List<LiveTableType>();
    mandatorySyncTablesTags.add(LiveTableType.TECHVIZ_MOBILE_TASK);
    mandatorySyncTablesTags.add(LiveTableType.TECHVIZ_MOBILE_TASK_STATUS);
    mandatorySyncTablesTags.add(LiveTableType.TECHVIZ_MOBILE_TASK_TYPE);
    mandatorySyncTablesTags.add(LiveTableType.TECHVIZ_MOBILE_ROLE);
    mandatorySyncTablesTags.add(LiveTableType.TECHVIZ_MOBILE_USER_ROLE);
    mandatorySyncTablesTags.add(LiveTableType.TECHVIZ_MOBILE_USER);
    mandatorySyncTablesTags.add(LiveTableType.TECHVIZ_MOBILE_USER_STATUS);
    mandatorySyncTablesTags.add(LiveTableType.TECHVIZ_MOBILE_SECTION);
    mandatorySyncTablesTags.add(LiveTableType.TECHVIZ_MOBILE_USER_SECTION);
    mandatorySyncTablesTags.add(LiveTableType.TECHVIZ_MOBILE_TASK_URGENCY);
    mandatorySyncTablesTags.add(LiveTableType.TECHVIZ_MOBILE_USER_GENERAL_INFO);


    List<LiveTableType> laterSyncTablesTags = List<LiveTableType>();
    laterSyncTablesTags.add(LiveTableType.TECHVIZ_MOBILE_SLOTS);
    laterSyncTablesTags.add(LiveTableType.TECHVIZ_MOBILE_RESERVATION_TIME);


    LiveTables = List<LiveTable>();
    for(dynamic liveTable in liveTableslist){
      String liveTableTag = liveTable['tags'] as String;
      if(liveTableTag.length==0)
        continue;

      liveTableTag = 'LiveTableType.$liveTableTag';

      LiveTableType liveTableTagTyped = LiveTableType.values.firstWhere((e)=> e.toString() == liveTableTag, orElse: () => null);

      if(liveTableTagTyped==null)
        continue;

      if(mandatorySyncTablesTags.contains(liveTableTagTyped)){
        LiveTables.add(LiveTable(liveTable['ID'].toString(), liveTableTag, []));
      }
      else if(laterSyncTablesTags.contains(liveTableTagTyped)){
        LiveTables.add(LiveTable(liveTable['ID'].toString(), liveTableTag, [], initialSync: false));
      };
    }

    print('Setup is done');

  }

  LiveTable GetLiveTable(String Tag){
    assert(DocumentID!=null);
    assert(LiveTables!=null);

    LiveTable lt = LiveTables.firstWhere((LiveTable lt) => lt.Tags == Tag, orElse: () => null);
    if(lt==null){
      throw Exception('No livetable for ${Tag}');
    }
    return lt;
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
  TECHVIZ_MOBILE_USER_GENERAL_INFO
}

class LiveTable{
  final String ID;
  final String Tags;
  final List<String> Columns;
  final bool initialSync;

  LiveTable(this.ID, this.Tags, this.Columns, {this.initialSync = true});
}