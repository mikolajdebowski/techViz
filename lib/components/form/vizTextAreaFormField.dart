import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class VizTextAreaFormField extends FormField<String> {
	VizTextAreaFormField({
		Key key,
		String labelText,
		IconData leadingIcon,
		TextEditingController textEditingController
	}) : super(
		key: key,
		builder: (FormFieldState<String> field) {
			return TextFormField(
					maxLength: 4000,
					maxLines: 3,
					style: TextStyle(color: Colors.white, fontSize: 14),
					controller: textEditingController,
					textInputAction: TextInputAction.done,
					cursorColor: const Color(0xFF424242),
					decoration: InputDecoration(
						labelStyle: TextStyle(color: Colors.white, fontSize: 16),
						isDense: true,
						focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black45)),
						icon: Icon(leadingIcon, color: Colors.white),
						labelText: labelText,
					));
		},
	);
}