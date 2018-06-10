import 'package:flutter/material.dart';
import 'package:techviz/adapters/searchAdapter.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizElevated.dart';

class VizSearch extends StatefulWidget {
  VizSearch({Key key, this.domain, this.onOKTapTapped, this.onBackTapped, this.searchAdapter})
      : super(key: key);

  final String domain;
  final VoidCallback onOKTapTapped;
  final VoidCallback onBackTapped;

  final SearchAdapter searchAdapter;

  @override
  State<StatefulWidget> createState() {
    return VizSearchState();
  }
}

class VizSearchState<T> extends State<VizSearch> {
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
                          hintText: 'Search for ${widget.domain}',
                          hintStyle: TextStyle(color: Colors.grey),
                          icon: Icon(Icons.search, color: Colors.white70))))),
        ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: ActionBar(centralWidgets: searchComponent),
      body: FutureBuilder<List<T>>(
        future: widget.searchAdapter.find(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(children: widget.searchAdapter.render(snapshot.data));
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner
          return Center(child: CircularProgressIndicator());
        },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
