import 'dart:async';
import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/repository/processor/processorLiveTable.dart';
import 'package:techviz/repository/slotFloorRepository.dart';

import 'processorRepositoryConfig.dart';

class ProcessorSlotFloorRepository extends ProcessorLiveTable<SlotMachine> implements ISlotFloorRemoteRepository {
  ProcessorSlotFloorRepository(IProcessorRepositoryConfig config) : super(config: config);

  @override
  Future<List<Map>> fetch() async {
    dynamic fetched = await fetchMapByTAG('TECHVIZ_MOBILE_SLOTS');
    return fetched as List<Map>;
  }

  @override
  Future<List<Map>> slotFloorSummary() async {
    return await fetchMapByTAG('TECHVIZ_MOBILE_SLOTFLOOR_SUMMARY') as List<Map>;
  }
}