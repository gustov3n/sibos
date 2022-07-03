import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sibos/form_builder/form_date.dart';
import 'package:sibos/form_builder/form_dropdown.dart';
import 'package:sibos/form_builder/form_photo.dart';
import 'package:sibos/form_builder/form_text.dart';
import 'package:sibos/helpers/helper.dart';
import 'package:sibos/models/model_dropdown.dart';
import 'package:http/http.dart' as http;

import 'form_time.dart';

class FormBuilder extends StatefulWidget {
  final List<FormBuilderConfig> configs;
  final String? actionUrl;
  final String submitLabel;
  final Map<String, dynamic>? additionalData;
  final Function(HttpPostResponse)? onSuccess;
  final bool enabled;

  const FormBuilder({
    required this.configs,
    this.actionUrl,
    this.submitLabel = "Simpan",
    this.additionalData,
    this.onSuccess,
    this.enabled = true,
    Key? key,
  }) : super(key: key);

  @override
  FormBuilderState createState() => FormBuilderState();
}

class FormBuilderState extends State<FormBuilder> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _values = {};
  final List<Widget> _widgets = [];

  bool _loading = false;

  void _generateForm() {
    _formKey = GlobalKey<FormState>();
    _values.clear();
    _widgets.clear();

    widget.configs.asMap().forEach(
      (index, config) {
        // Create input
        switch (config.type) {
          case FormInputType.hidden:
            _values[config.name] = config.value ?? "";
            break;
          case FormInputType.text:
            _values[config.name] =
                TextEditingController(text: config.value ?? "");

            _widgets.add(
              FormText(
                readOnly: config.readOnly || !widget.enabled,
                controller: _values[config.name],
                label: config.label,
                maxLength: config.maxLength,
                validator: config.required
                    ? (value) {
                        if (value == null || value.isEmpty) {
                          return "Harap diisi";
                        }
                        return null;
                      }
                    : null,
                icon: config.icon,
              ),
            );
            break;
          case FormInputType.textarea:
            _values[config.name] =
                TextEditingController(text: config.value ?? "");

            _widgets.add(
              FormText(
                readOnly: config.readOnly || !widget.enabled,
                controller: _values[config.name],
                label: config.label,
                maxLength: config.maxLength,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                validator: config.required
                    ? (value) {
                        if (value == null || value.isEmpty) {
                          return "Harap diisi";
                        }
                        return null;
                      }
                    : null,
                icon: config.icon,
              ),
            );
            break;
          case FormInputType.number:
            _values[config.name] =
                TextEditingController(text: config.value ?? "");

            _widgets.add(
              FormText(
                readOnly: config.readOnly || !widget.enabled,
                controller: _values[config.name],
                label: config.label,
                keyboardType: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: config.maxLength,
                validator: config.required
                    ? (value) {
                        if (value == null || value.isEmpty) {
                          return "Harap diisi";
                        }
                        return null;
                      }
                    : null,
                icon: config.icon,
              ),
            );
            break;
          case FormInputType.date:
            _values[config.name] = DateTime.now();
            if (config.value != null) {
              _values[config.name] = config.value;
            }

            _widgets.add(
              FormDate(
                readOnly: config.readOnly || !widget.enabled,
                initialDate: _values[config.name],
                controller: TextEditingController(),
                label: config.label,
                onChanged: (value) {
                  _values[config.name] = value;
                },
                validator: config.required
                    ? (value) {
                        if (value == null || value.isEmpty) {
                          return "Harap diisi";
                        }
                        return null;
                      }
                    : null,
              ),
            );
            break;
          case FormInputType.time:
            _values[config.name] = TimeOfDay.now();

            if (config.value != null) {
              _values[config.name] = config.value;
            }

            _widgets.add(
              FormTime(
                readOnly: config.readOnly || !widget.enabled,
                initialTime: _values[config.name],
                controller: TextEditingController(),
                label: config.label,
                onChanged: (value) {
                  _values[config.name] = value;
                },
                validator: config.required
                    ? (value) {
                        if (value == null || value.isEmpty) {
                          return "Harap diisi";
                        }
                        return null;
                      }
                    : null,
              ),
            );
            break;
          case FormInputType.photo:
            _widgets.add(FormPhoto(
              label: config.label,
              readOnly: config.readOnly || !widget.enabled,
              onChanged: (value) {
                _values[config.name] = value;
              },
            ));
            break;
          case FormInputType.photosRow:
            if (config.photosRowNames.length != config.photosRowLabels.length) {
              throw FlutterError("Labels and names length mismatch");
            }

            _widgets.add(
              Row(
                children: List.generate(
                  config.photosRowNames.length,
                  (index) => Expanded(
                    child: FormPhoto(
                      label: config.photosRowLabels[index],
                      readOnly: config.readOnly || !widget.enabled,
                      onChanged: (value) {
                        _values[config.photosRowNames[index]] = value;
                      },
                      initialValue: config.value[index] ?? "",
                    ),
                  ),
                ),
              ),
            );
            break;
          case FormInputType.select:
            _values[config.name] = ModelDropdown();

            _widgets.add(
              FormDropdown(
                url: config.urlForSelect,
                controller: TextEditingController(),
                defaultId: config.value,
                label: config.label,
                readOnly: config.readOnly || !widget.enabled,
                validator: config.required
                    ? (value) {
                        if (value == null || value.isEmpty) {
                          return "Harap diisi";
                        }
                        return null;
                      }
                    : null,
                onChange: (value) {
                  _values[config.name] = value;
                },
              ),
            );
            break;
          case FormInputType.customWidget:
            if (config.customWidget != null) {
              _widgets.add(config.customWidget!);
            }
            break;
          default:
            _widgets.add(const Text("Unknown Form Type"));
            break;
        }
      },
    );
  }

  void _submit() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    // Validate
    if (_formKey.currentState!.validate()) {
      if (widget.actionUrl == null) {
        setState(() {
          _loading = false;
        });
        return;
      }

      // Create request
      var uri = Uri.parse(widget.actionUrl!);
      var request = http.MultipartRequest("POST", uri);

      // Add fields
      widget.configs.asMap().forEach(
        (key, config) async {
          switch (config.type) {
            case FormInputType.hidden:
              request.fields[config.name] = _values[config.name];
              break;
            case FormInputType.text:
            case FormInputType.textarea:
            case FormInputType.number:
              request.fields[config.name] = _values[config.name].text;
              break;
            case FormInputType.date:
              request.fields[config.name] = _formatDate(_values[config.name]);
              break;
            case FormInputType.time:
              request.fields[config.name] = _formatTime(_values[config.name]);
              break;
            case FormInputType.photo:
              if (_values[config.name] != null) {
                request.files.add(await http.MultipartFile.fromPath(
                    config.name, _values[config.name].path));
              }
              break;
            case FormInputType.photosRow:
              for (var element in config.photosRowNames) {
                if (_values[element] != null) {
                  request.files.add(await http.MultipartFile.fromPath(
                      element, _values[element].path));
                }
              }
              break;
            case FormInputType.select:
              request.fields[config.name] = _values[config.name].id;
              break;
            case FormInputType.customWidget:
              break;
          }
        },
      );

      // Additional data
      widget.additionalData?.forEach((key, value) {
        request.fields[key] = value;
      });

      // Send request
      log("POST ${widget.actionUrl ?? ""} : \n${request.fields}");

      if (widget.actionUrl == null) {
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
        return;
      }

      HttpPostResponse response = await request.send().then(
        (streamedResponse) async {
          // Convert streamed response as string
          String response = await streamedResponse.stream.bytesToString();

          try {
            log("Response from ${widget.actionUrl ?? ""} : \n$response");
            // log("Response received from $url");

            // Result
            var json = jsonDecode(response);
            return HttpPostResponse.fromJson(json);
          } on SocketException {
            return HttpPostResponse(
              message: "No internet connection",
              responseBody: response,
            );
          } on HttpException {
            return HttpPostResponse(
              message: "Couldn't connect to server",
              responseBody: response,
            );
          } on FormatException {
            return HttpPostResponse(
              message: "Bad response format",
              responseBody: response,
            );
          } on http.ClientException {
            return HttpPostResponse(
              message: "Client error",
              responseBody: response,
            );
          }
        },
      );

      if (response.success) {
        // Call onSubmit (if exist)
        widget.onSuccess?.call(response);
      } else {
        if (mounted) {
          Helper.alert(
            context: context,
            message: response.message,
            details: response.responseBody,
            type: AlertType.error,
          );
        }
      }

      log(response.toString());
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatTime(TimeOfDay time) {
    var temp = DateTime(0, 0, 0, time.hour, time.minute);
    return DateFormat('HH:mm:ss').format(temp);
  }

  @override
  void initState() {
    super.initState();
    _generateForm();
  }

  @override
  void didUpdateWidget(covariant FormBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only regenerate form if configs are changed
    if (widget.configs != oldWidget.configs) {
      _generateForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _widgets,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ElevatedButton(
              onPressed: _loading || !widget.enabled ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    )
                  : Text(widget.submitLabel),
            ),
          ),
        ],
      ),
    );
  }
}

//----------------
class FormBuilderConfig {
  final String name;
  final String label;
  final FormInputType type;
  final bool required;
  final bool readOnly;
  final Widget? customWidget;
  final dynamic value;
  final String urlForSelect;
  final int? maxLength;
  final List<String> photosRowNames;
  final List<String> photosRowLabels;
  final Icon? icon;

  FormBuilderConfig({
    required this.name,
    this.label = "",
    this.type = FormInputType.text,
    this.required = false,
    this.customWidget,
    this.value,
    this.urlForSelect = "",
    this.maxLength,
    this.photosRowNames = const [],
    this.photosRowLabels = const [],
    this.readOnly = false,
    this.icon,
  });
}

enum FormInputType {
  hidden,
  text,
  textarea,
  number,
  date,
  time,
  photo,
  select,
  customWidget,
  photosRow,
}
