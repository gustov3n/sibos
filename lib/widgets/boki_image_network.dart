import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BokiImageNetwork extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const BokiImageNetwork({
    required this.url,
    this.width,
    this.height,
    this.fit,
    this.loadingWidget,
    this.errorWidget,
    Key? key,
  }) : super(key: key);

  @override
  BokiImageNetworkState createState() => BokiImageNetworkState();
}

class BokiImageNetworkState extends State<BokiImageNetwork> {
  Uint8List _imgBytes = Uint8List(0);
  String _error = "";
  bool _loading = true;

  void _loadImage() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      var response = await http.get(Uri.parse(widget.url));

      if (response.statusCode == 200) {
        _imgBytes = response.bodyBytes;
      } else {
        _error = "Error : ${response.statusCode}";
      }
    } catch (e) {
      _error = e.toString();
      log("Image error : $e");
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
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant BokiImageNetwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadImage();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return widget.loadingWidget ?? const SizedBox();
    } else {
      if (_imgBytes.isEmpty) {
        if (widget.errorWidget != null) {
          return widget.errorWidget!;
        } else {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: Center(
              child: Text(
                _error,
                style: TextStyle(color: Theme.of(context).errorColor),
              ),
            ),
          );
        }
      }

      return Image.memory(
        _imgBytes,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
      );
    }
  }
}
