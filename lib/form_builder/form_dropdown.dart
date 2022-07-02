import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sibos/helpers/helper.dart';
import 'package:sibos/helpers/textstyles.dart';
import 'package:sibos/models/model_dropdown.dart';

class FormDropdown extends StatefulWidget {
  final String url;
  final String label;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final Function(ModelDropdown)? onChange;
  final String? defaultId;
  final bool readOnly;

  const FormDropdown({
    required this.url,
    this.label = "",
    this.validator,
    this.controller,
    this.onChange,
    this.defaultId,
    this.readOnly = false,
    Key? key,
  }) : super(key: key);

  @override
  _FormDropdownState createState() => _FormDropdownState();
}

class _FormDropdownState extends State<FormDropdown> {
  bool _loading = false;

  void _showDialog() async {
    if (widget.readOnly) {
      return;
    }

    ModelDropdown? selected = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              widget.label,
              style: textStyleBold,
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            content: FormDropDownDialog(
              parent: widget,
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Batal"))
            ],
          );
        });

    if (selected != null) {
      // Set input text
      widget.controller?.text = selected.text;

      // Trigger onChange
      widget.onChange?.call(selected);
    }
  }

  void _loadDefault() async {
    if (widget.defaultId == null) {
      return;
    }
    if (widget.defaultId!.isEmpty || widget.defaultId == "0") {
      return;
    }

    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    // Request with default id (must be only one result)
    HttpPostResponse response = await Helper.sendHttpPost(
      widget.url,
      postData: {
        "limit": "1",
        "page": "0",
        "search": "",
        "id": widget.defaultId,
      },
    );

    if (response.success) {
      if (response.data.length > 0) {
        ModelDropdown defaultValue = ModelDropdown.fromJson(response.data[0]);

        // Set input text
        widget.controller?.text = defaultValue.text;

        // Trigger onChange
        widget.onChange?.call(defaultValue);
      }
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

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDefault();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          TextFormField(
            enabled: !_loading && !widget.readOnly,
            readOnly: true,
            showCursor: false,
            controller: widget.controller,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: widget.validator,
            onTap: !_loading ? _showDialog : null,
            decoration: InputDecoration(
              labelText: widget.label,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              border: OutlineInputBorder(borderRadius: Helper.borderRadius),
              prefixIconConstraints: BoxConstraints.tight(
                const Size(48, 16),
              ),
              prefixIcon: _loading
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const CircularProgressIndicator(),
                    )
                  : null,
              suffixIcon: const Icon(
                Icons.arrow_drop_down,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FormDropDownDialog extends StatefulWidget {
  final FormDropdown parent;

  const FormDropDownDialog({
    required this.parent,
    Key? key,
  }) : super(key: key);

  @override
  _FormDropDownDialogState createState() => _FormDropDownDialogState();
}

class _FormDropDownDialogState extends State<FormDropDownDialog> {
  final ScrollController _conList = ScrollController();
  int _page = 0;
  final int _limit = 10;
  bool _endOfPage = false;
  final List<ModelDropdown> _list = [];
  bool _error = false;

  final TextEditingController _conSearch = TextEditingController();
  Timer? _debounce;

  void _loadMoreData(int index) async {
    if (_error) return;

    HttpPostResponse response = await Helper.sendHttpPost(
      widget.parent.url,
      postData: {
        "limit": _limit.toString(),
        "page": _page.toString(),
        "search": _conSearch.text,
      },
    );

    if (response.success) {
      for (var data in response.data) {
        _list.add(ModelDropdown.fromJson(data));
      }

      // End of page
      if (response.data.length == 0) {
        _endOfPage = true;
      }

      _page++;
    } else {
      if (mounted) {
        Helper.alert(
          context: context,
          message: response.message,
          details: response.responseBody,
          type: AlertType.error,
        );
      }
      _error = true;
    }

    if (mounted) setState(() {});
  }

  void _onSearchChanged(String searchText) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _resetList();
    });
  }

  void _resetList() {
    _page = 0;
    _endOfPage = false;
    _conList.jumpTo(0);
    _list.clear();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _conSearch,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: Helper.borderRadius,
            ),
            contentPadding: const EdgeInsets.all(8),
            fillColor: Colors.white,
            hintText: "Cari",
            prefixIcon: const Icon(
              Icons.search,
            ),
            suffixIcon: IconButton(
              onPressed: () => setState(() {
                _conSearch.clear();
                _resetList();
              }),
              icon: const Icon(Icons.close),
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              controller: _conList,
              itemBuilder: (context, index) {
                if (index < _list.length) {
                  var item = _list[index];
                  return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(item),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(item.text),
                        ),
                      ));
                } else {
                  if (!_endOfPage) {
                    _loadMoreData(index);
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          "-- akhir dari halaman --",
                          style:
                              TextStyle(color: Theme.of(context).disabledColor),
                        ),
                      ),
                    );
                  }
                }
              },
              itemCount: _list.length + 1,
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
