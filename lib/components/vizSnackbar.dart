import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class VizSnackbar{
	Flushbar _flushbar;

	VizSnackbar(String message, IconData iconData, Color indicatorColor, Duration duration, {bool showProgressIndicator = false, FlatButton mainButton}){
		_flushbar = Flushbar(
				mainButton: mainButton,
				overlayBlur: 1.0,
				message: message,
				showProgressIndicator: showProgressIndicator,
				icon: Icon(iconData, color: indicatorColor),
				duration: duration,
				animationDuration: Duration(milliseconds: 500));
	}

	Future<Object> show(BuildContext context){
		return _flushbar.show(context);
	}

	Future<Object> dismiss(){
		return _flushbar.dismiss();
	}

	static VizSnackbar Info(String message) {
		return VizSnackbar(message, Icons.info, Colors.white, Duration(seconds: 5));
	}

	static VizSnackbar Success(String message) {
		return VizSnackbar(message, Icons.check_circle, Colors.green, Duration(seconds: 5));
	}

	static VizSnackbar Error(String message, {FlatButton mainButton}) {
		return VizSnackbar(message, Icons.error, Colors.red, Duration(seconds: 10), mainButton: mainButton);
	}

	static VizSnackbar Loading(String message) {
		return VizSnackbar(message, Icons.sync, Colors.white, null, showProgressIndicator : true);
	}


}