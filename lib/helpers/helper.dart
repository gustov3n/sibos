import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sibos/helpers/textstyles.dart';
import 'package:sibos/widgets/overlay_loading.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Helper {
  static BorderRadius borderRadius = BorderRadius.circular(10);

  /// Send HTTP POST request
  static Future<HttpPostResponse> sendHttpPost(
    String url, {
    Object? postData,
  }) async {
    HttpPostResponse out = HttpPostResponse();

    try {
      // Request API
      log("POST  $url : \n" + postData.toString());
      http.Response response = await http.post(Uri.parse(url), body: postData);
      log("Response from $url : \n" + response.body);
      out.responseBody = response.body;
      // log("Response received from $url");

      // Result
      var json = jsonDecode(response.body);
      return HttpPostResponse.fromJson(json);
    } on SocketException {
      out.message = "No internet connection";
    } on HttpException {
      out.message = "Couldn't connect to server";
    } on FormatException {
      out.message = "Bad response format";
    } on http.ClientException {
      out.message = "Client error";
    }

    return out;
  }

  /// Get device screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get device screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Show a snackbar
  ///
  /// WARNING : make sure to check [State.mounted] before calling this
  static void snackBar(context, message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
      backgroundColor: Colors.red,
      action: SnackBarAction(
        label: "Close",
        textColor: Colors.white,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Generate a random image url from picsum
  static String randomPicURL() {
    DateTime date = DateTime.now();
    var seed = date.millisecond;
    return "https://picsum.photos/seed/$seed/400/600?random=$seed";
  }

  /// Format [DateTime] to readable 'dd MMM yyyy'
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Format [DateTime] to 'y-M-d', usually used to save to DB
  static String formatDateToDB(DateTime date) {
    return DateFormat('y-M-d').format(date);
  }

  /// Extract clock from [DateTime] with format 'H:m'
  static String extractClock(DateTime date) {
    var result = DateFormat.Hm().format(date);
    return result;
    //DateFormat('jm').format(date);
  }

  /// Format [TimeOfDay] to 'HH:mm'
  static String formatTime(TimeOfDay time) {
    var temp = DateTime(0, 0, 0, time.hour, time.minute);
    return DateFormat('HH:mm').format(temp);
  }

  /// Get shared preferences value by key
  static Future<String> getPrefs(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "";
  }

  /// Delaying async methods
  static Future<dynamic> delay(int seconds) {
    return Future.delayed(Duration(seconds: seconds));
  }

  /// Show an alert box with icon, title and message
  ///
  /// WARNING : make sure to check [State.mounted] before calling this
  static Future<T?> alert<T>({
    required BuildContext context,
    String? message,
    AlertType? type = AlertType.info,
    String? details,
  }) {
    Color iconColor;
    IconData? icon;
    switch (type) {
      case AlertType.info:
        icon = FontAwesomeIcons.circleInfo;
        iconColor = Theme.of(context).colorScheme.primary;
        break;
      case AlertType.success:
        icon = FontAwesomeIcons.solidCircleCheck;
        iconColor = Theme.of(context).colorScheme.primary;
        break;
      case AlertType.error:
        icon = FontAwesomeIcons.circleExclamation;
        iconColor = Theme.of(context).colorScheme.error;
        break;
      default:
        icon = FontAwesomeIcons.circleInfo;
        iconColor = Theme.of(context).colorScheme.primary;
        break;
    }
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(
                icon,
                color: iconColor,
                size: 64,
              ),
            ),
            Text(message ?? ""),
          ],
        ),
        actions: [
          if (details?.isNotEmpty ?? false)
            OutlinedButton(
              child: const Text("Details"),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: Scrollbar(
                    child: SingleChildScrollView(
                      child: Text(
                        details!
                            .replaceAll(RegExp(r"<head>[.\s\S]*<\/head>"), ""),
                        style: textStyleSmall,
                      ),
                    ),
                  ),
                  actions: [
                    OutlinedButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: details));
                      },
                      child: const Text("Copy"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// Show a confirmation dialog
  ///
  /// WARNING : make sure to check [State.mounted] before calling this
  static Future<bool> confirm({
    required BuildContext context,
    String? message,
    AlertType? type = AlertType.info,
  }) async {
    Color iconColor;
    IconData? icon;
    switch (type) {
      case AlertType.info:
        icon = FontAwesomeIcons.circleInfo;
        iconColor = Theme.of(context).colorScheme.primary;
        break;
      case AlertType.success:
        icon = FontAwesomeIcons.solidCircleCheck;
        iconColor = Theme.of(context).colorScheme.primary;
        break;
      case AlertType.error:
        icon = FontAwesomeIcons.circleExclamation;
        iconColor = Theme.of(context).colorScheme.error;
        break;
      default:
        icon = FontAwesomeIcons.circleInfo;
        iconColor = Theme.of(context).colorScheme.primary;
        break;
    }
    bool? confirm = await showDialog<bool?>(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(
                icon,
                color: iconColor,
                size: 64,
              ),
            ),
            Text(message ?? ""),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Ya"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Tidak"),
          ),
        ],
      ),
    );

    return confirm ?? false;
  }

  /// Get app version
  static Future<String> appVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return "v${packageInfo.version}b${packageInfo.buildNumber}";
  }

  /// Show a loading overlay
  ///
  /// Just call [Navigator.pop] to close
  static void loading(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => const OverlayLoading(),
      ),
    );
  }
}

/// Model for sendHttpPost
class HttpPostResponse {
  bool success;
  String message;
  dynamic data;
  String responseBody;

  HttpPostResponse({
    this.success = false,
    this.message = "",
    this.data,
    this.responseBody = "",
  });

  @override
  String toString() {
    return "success: $success, message: $message, data: $data, ";
  }

  factory HttpPostResponse.fromJson(Map<String, dynamic> json) {
    return HttpPostResponse(
      success: json["success"],
      message: json["message"],
      data: json["data"],
    );
  }
}

enum AlertType { info, success, error }
