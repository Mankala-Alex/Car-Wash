import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CommonPageSearch extends StatelessWidget {
  final String txtHintValue;
  final VoidCallback? searchEvent;
  final ValueChanged<String>? onChanged;
  final bool? showShadow;
  final TextEditingController? controller;

  const CommonPageSearch({
    super.key,
    required this.txtHintValue,
    this.searchEvent,
    this.onChanged,
    this.showShadow = true,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final customTheme = CustomTheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      // margin: Constants.paddingSymmetric1020,
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      decoration: BoxDecoration(
        color: customTheme.bgColor,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        boxShadow: showShadow == true
            ? const [
                BoxShadow(
                  color: Color.fromRGBO(184, 200, 224, 0.22),
                  offset: Offset(0, 1), // Horizontal and vertical offset
                  blurRadius: 2.0, // Blur radius
                  spreadRadius: 0.0, // Spread radius
                ),
              ]
            : null,
      ),
      child: TextFormField(
        autofocus: false,
        onChanged: onChanged,
        controller: controller,
        decoration: InputDecoration(
          hintText: txtHintValue,
          hintStyle: TextStyle(fontSize: textTheme.bodySmall?.fontSize, color: customTheme.textLightGray),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.5),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 1.5),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 1.5),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          suffixIcon: IconButton(
            onPressed: searchEvent,
            icon: Icon(
              Icons.search_outlined,
              size: 30,
              color: customTheme.textLightGray,
            ),
          ),
        ),
      ),
    );
  }
}
