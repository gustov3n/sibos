import 'package:flutter/material.dart';
import 'package:sibos/helpers/helper.dart';

class FormDate extends StatefulWidget {
  final String label;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final DateTime initialDate;
  final Function(DateTime)? onChanged;
  final bool readOnly;

  const FormDate({
    required this.initialDate,
    this.label = "",
    this.validator,
    this.controller,
    this.onChanged,
    this.readOnly = false,
    Key? key,
  }) : super(key: key);

  @override
  _FormDateState createState() => _FormDateState();
}

class _FormDateState extends State<FormDate> {
  DateTime _newDate = DateTime.now();

  void _showDatePicker() async {
    _newDate = await showDatePicker(
          context: context,
          currentDate: widget.initialDate,
          initialDate: _newDate,
          firstDate: DateTime(widget.initialDate.year - 10, 1),
          lastDate: DateTime(widget.initialDate.year + 10, 1),
        ) ??
        _newDate;

    widget.controller?.text = Helper.formatDate(_newDate);

    if (widget.onChanged != null) {
      widget.onChanged!(_newDate);
    }

    if (mounted) setState(() {});
  }

  void _init() {
    _newDate = widget.initialDate;
    widget.controller?.text = Helper.formatDate(_newDate);

    if (widget.onChanged != null) {
      widget.onChanged!(_newDate);
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: widget.controller,
        enabled: !widget.readOnly,
        readOnly: true,
        showCursor: false,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: widget.validator,
        onTap: !widget.readOnly ? _showDatePicker : null,
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: const Icon(
            Icons.calendar_today,
            size: 16,
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 28, maxWidth: 28),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          // border: OutlineInputBorder(borderRadius: Helper.borderRadius),
        ),
      ),
    );
  }
}
