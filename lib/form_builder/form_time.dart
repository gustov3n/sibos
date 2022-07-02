import 'package:flutter/material.dart';
import 'package:sibos/helpers/helper.dart';

class FormTime extends StatefulWidget {
  final String label;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final TimeOfDay initialTime;
  final Function(TimeOfDay)? onChanged;
  final bool readOnly;

  const FormTime({
    required this.initialTime,
    this.label = "",
    this.validator,
    this.controller,
    this.onChanged,
    this.readOnly = false,
    Key? key,
  }) : super(key: key);

  @override
  _FormTimeState createState() => _FormTimeState();
}

class _FormTimeState extends State<FormTime> {
  TimeOfDay _newTime = TimeOfDay.now();

  void _showTimePicker() async {
    _newTime = await showTimePicker(
          context: context,
          initialTime: widget.initialTime,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: true,
              ),
              child: child!,
            );
          },
        ) ??
        _newTime;

    widget.controller?.text = Helper.formatTime(_newTime);

    if (widget.onChanged != null) {
      widget.onChanged!(_newTime);
    }

    if (mounted) setState(() {});
  }

  void _init() {
    _newTime = widget.initialTime;
    widget.controller?.text = Helper.formatTime(_newTime);

    if (widget.onChanged != null) {
      widget.onChanged!(_newTime);
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
        onTap: !widget.readOnly ? _showTimePicker : null,
        decoration: InputDecoration(
          labelText: widget.label,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          border: OutlineInputBorder(borderRadius: Helper.borderRadius),
        ),
      ),
    );
  }
}
