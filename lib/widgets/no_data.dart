import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NoData extends StatelessWidget {
  const NoData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Icon(
              FontAwesomeIcons.faceMeh,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Text("Tidak ada data"),
        ],
      ),
    );
  }
}
