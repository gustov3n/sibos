import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sibos/helpers/global.dart';
import 'package:sibos/helpers/helper.dart';
import 'package:sibos/widgets/boki_image_network.dart';

class FormPhoto extends StatefulWidget {
  final String label;
  final Function(XFile?)? onChanged;
  final String initialValue;
  final bool readOnly;

  const FormPhoto({
    this.label = "",
    this.onChanged,
    this.initialValue = "",
    this.readOnly = false,
    Key? key,
  }) : super(key: key);

  @override
  FormPhotoState createState() => FormPhotoState();
}

class FormPhotoState extends State<FormPhoto> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  void _pickPhoto() async {
    if (widget.readOnly) {
      return;
    }

    ImageSource? source = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Center(
          child: Text(widget.label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Batal"),
          ),
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text("Ambil gambar dari : "),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FontAwesomeIcons.images,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          const Text("Gallery"),
                        ],
                      ),
                    ),
                  ),
                ),
                Card(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(ImageSource.camera),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FontAwesomeIcons.camera,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          const Text("Camera"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      _pickPhotoConfirm(source);
    }
  }

  void _pickPhotoConfirm(ImageSource source) async {
    _image = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 80,
    );
    widget.onChanged?.call(_image);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        // shadowColor: Colors.transparent,
        // color: Theme.of(context).colorScheme.background,
        // shape: RoundedRectangleBorder(
        //   borderRadius: Helper.borderRadius,
        //   side: BorderSide(color: Theme.of(context).disabledColor),
        // ),
        decoration: BoxDecoration(
          borderRadius: Helper.borderRadius,
          border: Border.all(
            color: Theme.of(context).disabledColor,
          ),
        ),
        child: InkWell(
          onTap: _pickPhoto,
          child: SizedBox(
            width: double.infinity,
            height: 200,
            child: _image == null
                ? widget.initialValue.isNotEmpty
                    ? FittedBox(
                        fit: BoxFit.cover,
                        child: BokiImageNetwork(
                          url: baseURLUploads + widget.initialValue,
                          errorWidget: SizedBox(
                            width: 64,
                            height: 64,
                            child: Center(
                              child: Icon(
                                FontAwesomeIcons.faceFrown,
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                          ),
                        ),
                        // Image.network(
                        //   baseURLUploads +
                        //       widget.initialValue +
                        //       "?v=" +
                        //       math.Random().nextInt(100).toString(),
                        //   errorBuilder: (context, error, stackTrace) => Center(
                        //     child: Icon(
                        //       Icons.image_not_supported_outlined,
                        //     ),
                        //   ),
                        // ),
                      )
                    : Column(
                        children: [
                          const Spacer(),
                          Icon(
                            FontAwesomeIcons.image,
                            color: Theme.of(context).disabledColor,
                            size: 32,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(widget.label),
                          const Spacer(),
                        ],
                      )
                : FittedBox(
                    fit: BoxFit.cover,
                    child: Image.file(
                      File(_image!.path),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
