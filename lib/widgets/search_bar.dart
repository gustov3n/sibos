import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sibos/helpers/helper.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Function()? onSearch;

  const SearchBar({
    this.controller,
    this.hintText,
    this.onSearch,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: Helper.borderRadius,
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: const Icon(
              FontAwesomeIcons.magnifyingGlass,
              size: 16,
            ),
            onPressed: onSearch,
          ),
        ),
      ),
    );
  }
}
