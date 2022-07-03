import 'package:flutter/material.dart';
import 'package:sibos/helpers/helper.dart';
import 'package:sibos/pages/maps/maps.dart';
import 'home_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  TextEditingController conSearch = TextEditingController();

  void onSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MapsPage(),
      ),
    );
  }

  Future<bool> onWillPop() async {
    return await Helper.confirm(
      context: context,
      message: "Keluar aplikasi?",
    );
  }

  @override
  void dispose() {
    conSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HomeView(this);
}
