import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:techviz/service/client/MQTTClientService.dart';

class NetworkIndicator extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _NetworkIndicatorState();
  }
}

/*
    Color of button icon indicates network status:
    Red    - Not connected to the "Local wifi connection"
    Orange - No connection to "VizExplorer services connection"
    Green  - No issues
  */
class _NetworkIndicatorState extends State<NetworkIndicator> {

  StreamSubscription<MQTTConnectionStatus> vizStatus;
  StreamSubscription<ConnectivityResult> wifiStatus;
  Color networkIndicatorColor = Colors.green;
  String wifiStatusMsg = "No issues";  // wifi 'Not connected' or 'No issues'
  String serviceStatusMsg = "No issues";  // service 'Not connected' or 'No issues'
  bool isWifiActive = true;
  bool isServiceActive = true;

  @override
  void initState() {
    super.initState();
    listenForMQTTStatusChange();
    listenForWifiStatusChange();
  }

  void listenForWifiStatusChange() {
    wifiStatus = Connectivity().onConnectivityChanged.listen((ConnectivityResult status) {
//    print('wifi status changed to: ${status.toString()}');
      setState(() {
        if(status == ConnectivityResult.wifi){
          isWifiActive = true;
          wifiStatusMsg = "No issues";
          networkIndicatorColor = Colors.green;
        }else if(status == ConnectivityResult.none || status == ConnectivityResult.mobile){
          isWifiActive = false;
          wifiStatusMsg = "Not connected";
          networkIndicatorColor = Colors.red;
        }
      });
    });
  }

  void listenForMQTTStatusChange() {
    vizStatus = MQTTClientService().status.listen((MQTTConnectionStatus status) async{
//    print('MQTT service status changed to: ${status.toString()}');
      ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();
      if(connectivityResult == ConnectivityResult.wifi){
        setState(() {
          if(status == MQTTConnectionStatus.Connected){
            isServiceActive = true;
            serviceStatusMsg = "No issues";
            networkIndicatorColor = Colors.green;
          }else{
            isServiceActive = false;
            serviceStatusMsg = "Not connected";
            networkIndicatorColor = Colors.orange;
          }
        });
      }
    });
  }

  void _openNetworkDialog(){
    setState(() {
      String wifiTxt = "Local Wifi Connection: ";
      String serviceTxt = "VizExplorer Service Connection: ";

      showDialog<bool>(context: context, builder: (BuildContext context) {
        if(isWifiActive) {
          return AlertDialog(
            title: Text('Network Status'),
            content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(children: <Widget>[
                    Text(wifiTxt),
                    Text(
                      wifiStatusMsg,
                      style: TextStyle(
                          color: Colors.green),
                    ),
                  ]),
                  Row(children: <Widget>[
                    Text(serviceTxt),
                    Text(
                      serviceStatusMsg,
                      style: TextStyle(
                          color: isServiceActive ? Colors.green : Colors.red),
                    ),
                  ]),
                ]),
            actions: <Widget>[
              FlatButton(
                child: Text("DONE"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              )
            ],
          );
        }else{
          return AlertDialog(
            title: Text('Network Status'),
            content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(children: <Widget>[
                    Text(wifiTxt),
                    Text(
                      wifiStatusMsg,
                      style: TextStyle(
                          color: Colors.red),
                    ),
                  ]),

                ]),
            actions: <Widget>[
              FlatButton(
                child: Text("DONE"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              )
            ],
          );
        }
      });
    });
  }

  @override
  void dispose() {
    if(wifiStatus != null){
      wifiStatus.cancel();
    }
    if(vizStatus != null){
      vizStatus.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _openNetworkDialog();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Network', style: TextStyle(color: Color(0xFF566474), fontSize: 13.0)),
          Container(
            margin: EdgeInsets.only(top: 2),
            width: 15,
            height: 15,
            decoration: BoxDecoration(
                color: networkIndicatorColor,
                shape: BoxShape.circle
            ),
          ),
        ],
      ),
    );
  }
}