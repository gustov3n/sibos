import 'package:flutter/material.dart';

class OverlayLoading extends StatefulWidget {
  const OverlayLoading({Key? key}) : super(key: key);

  @override
  State<OverlayLoading> createState() => _OverlayLoadingState();
}

class _OverlayLoadingState extends State<OverlayLoading> {
  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        color: Theme.of(context).colorScheme.surface.withOpacity(.75),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
