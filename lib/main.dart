import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sibos/helpers/helper.dart';
import 'package:sibos/pages/home/home.dart';

void main() {
  if (defaultTargetPlatform == TargetPlatform.android) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SIBOS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorScheme: ColorScheme(
          primary: Colors.blue,
          secondary: Colors.orange,
          surface: Colors.white,
          background: Colors.white70,
          error: Colors.red.shade700,
          onPrimary: Colors.white,
          onSecondary: Colors.orangeAccent,
          onSurface: Colors.black,
          onBackground: Colors.black,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        cardTheme: CardTheme(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: Helper.borderRadius,
          ),
          elevation: 8,
          shadowColor: Colors.black26,
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: Colors.blue,
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(borderRadius: Helper.borderRadius),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: Helper.borderRadius,
              ),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: Helper.borderRadius,
              ),
            ),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
