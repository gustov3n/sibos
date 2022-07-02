import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:sibos/helpers/helper.dart';

class FormText extends StatefulWidget {
  final String label;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final int? maxLength;
  final int? maxLines;
  final bool readOnly;
  final Function(String)? onChanged;
  final Icon? icon;
  final bool allowClearButton;

  const FormText({
    this.label = "",
    this.validator,
    this.controller,
    this.keyboardType,
    this.formatters,
    this.maxLength,
    this.maxLines = 1,
    this.readOnly = false,
    this.onChanged,
    this.icon,
    this.allowClearButton = false,
    Key? key,
  }) : super(key: key);

  @override
  _FormTextState createState() => _FormTextState();
}

class _FormTextState extends State<FormText> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        enabled: !widget.readOnly,
        readOnly: widget.readOnly,
        controller: widget.controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.formatters,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          counterText: "",
          labelText: widget.label,
          icon: widget.icon,
          // contentPadding: const EdgeInsets.symmetric(
          //   horizontal: 20,
          //   vertical: 8,
          // ),
          // border: OutlineInputBorder(borderRadius: Helper.borderRadius),
          suffixIcon: widget.allowClearButton &&
                  (widget.controller?.text.isNotEmpty ?? false)
              ? IconButton(
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  onPressed: () => setState(() {
                    widget.controller?.clear();
                    widget.onChanged?.call(widget.controller?.text ?? "");
                  }),
                  icon: const Icon(
                    FontAwesomeIcons.xmark,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
