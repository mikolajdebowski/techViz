import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:techviz/adapters/machineAdapter.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizElevated.dart';

class SlotLookup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SlotLookupState();
}

class SlotLookupState extends State<SlotLookup> {

  SlotAdapter adapter;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    adapter = SlotAdapter();
  }


  @override
  Widget build(BuildContext context) {


    var searchComponent = <Widget>[
      Expanded(
        child: VizElevated(
            customWidget: Padding(
                padding: const EdgeInsets.all(5.0),
                child: TextField(
                    style: TextStyle(color: Colors.white70),
                    decoration: InputDecoration(
                        isDense: true,

                        hintText: 'Search for slots...',
                        hintStyle: TextStyle(color: Colors.black54),
                        icon: Icon(Icons.search, color: Colors.white70))))),
      ),
    ];

    var builder = FutureBuilder<List<MachineModel>>(
      future: adapter.find(),
      builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(children: adapter.render(snapshot.data));
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
        // By default, show a loading spinner
        return Container(
            child: Center(child: CircularProgressIndicator()));
      },
    );


    return Scaffold(
        backgroundColor: Colors.black,
        appBar: ActionBar(centralWidgets: searchComponent),
        body: SafeArea(child: builder, top: false, bottom: false)

    );
    // TODO: implement build
  }

}