import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class VizDropdownFormField<T> extends FormField<T> {
	VizDropdownFormField({
		Key key,
		String labelText,
		IconData leadingIcon,
		T initialValue,
		List<DropdownMenuItem<T>> items,
		bool autovalidate = false,
		FormFieldSetter<T> onSaved,
		FormFieldValidator<T> validator,
		Function onChanged,
	}) : super(
		key: key,
		onSaved: onSaved,
		validator: validator,
		autovalidate: autovalidate,
		initialValue: items.contains(initialValue) ? initialValue : null,
		builder: (FormFieldState<T> field) {
			InputDecoration decoration = InputDecoration(
				contentPadding: EdgeInsets.only(top: 10.0),
				isDense: true,
				icon: Icon(leadingIcon, color: Colors.white),
				labelStyle: TextStyle(color: Colors.white),
				labelText: labelText,
			);

			return Theme(
						data: Theme.of(field.context).copyWith(canvasColor: Color(0xFF8B9EA7)),
						child: InputDecorator(
					decoration: decoration.copyWith(errorText: field.hasError ? field.errorText : null),
					isEmpty: field.value == '' || field.value == null,
					child: DropdownButtonHideUnderline(
						child: DropdownButton<T>(
							style: TextStyle(color: Colors.white, fontSize: 16),
							value: field.value,
							isDense: true,
							onChanged: (T value){
								field.didChange(value);
								onChanged(value);
							},
							items: items.toList(),
						),
					),
				)
			);
		},
	);
}