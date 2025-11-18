import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'custome_star_lable.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final List items;
  final String? selectedKey;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;
  final String hintText;
  final String? errorText;
  final bool isRequired;

  CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    this.selectedKey = "",
    required this.onChanged,
    this.hintText = "Select options",
    this.errorText,
    this.validator,
    this.isRequired = false,
  }) {
    if (!isValidSelectedKey(selectedKey)) {
      throw ArgumentError(
        'selectedKey must be a valid key from the items list',
      );
    }
  }

  bool isValidSelectedKey(String? selectedKey) {
    if (selectedKey == null || items.isEmpty) {
      return true;
    }
    return items.any((item) => item.keys.first == selectedKey);
  }
  // : assert(
  //         selectedKey == null ||
  //             items.isEmpty ||
  //             items.any((item) {
  //               debugPrint('Checking item: ${item.keys.first} against selectedKey: $selectedKey');
  //               return item.keys.first == selectedKey;
  //             }),
  //         // ||
  //         // (selectedKey == null && items.isNotEmpty && items.first.keys.first == ''),
  //         'selectedKey must be a valid key from the items list',
  //       );

  @override
  Widget build(BuildContext context) {
    final customTheme = CustomTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    // Add default empty item if items list is empty
    final List<Map<String, dynamic>> finalItems = items.isEmpty
        ? [
            {"": "Select"},
          ]
        : List<Map<String, dynamic>>.from(items);

    // Ensure the empty item is selected if no selectedKey is provided
    // final String? finalSelectedKey = selectedKey ?? (items.isEmpty ? "" : null);

    return Wrap(
      children: [
        Visibility(
          visible: label.isNotEmpty ?? false,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              //const SizedBox(width: 15),
              Text(
                label ?? "",
                style: TextStyle(
                  color: customTheme.textDefault,
                  fontSize: textTheme.labelMedium?.fontSize,
                  fontWeight: FontWeight.w400,
                ),
              ),
              isRequired ? const CustomeStarLable() : const SizedBox.shrink(),
              const SizedBox(height: 8),
              DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  // isDense: true,
                  initialValue: selectedKey,
                  isExpanded: true,
                  onChanged: onChanged,
                  // hint: Align(alignment: Alignment.centerLeft, child: Text(hintText)),
                  padding: const EdgeInsets.only(left: 10),
                  hint: Text(
                    hintText,
                    style: TextStyle(fontSize: textTheme.bodySmall?.fontSize),
                  ),
                  iconEnabledColor: customTheme.textDefault,
                  dropdownColor: customTheme.bgColor,
                  icon: const Icon(Icons.keyboard_arrow_down_outlined),
                  decoration: InputDecoration(
                    errorStyle: TextStyle(color: customTheme.errorColor),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: customTheme.borderLightGray,
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: customTheme.borderLightGray,
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: customTheme.borderLightGray,
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: customTheme.errorColor, width: 1),
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: customTheme.errorColor, width: 1),
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                    ),
                  ),
                  validator: validator,
                  selectedItemBuilder: (BuildContext context) {
                    return items.map<Widget>((item) {
                      // String key = item.keys.first;
                      String value = item.values.first;
                      return Container(
                        alignment: Alignment.centerLeft,
                        // padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          value,
                          style: TextStyle(
                            color: customTheme.textDefault,
                            fontSize: textTheme.bodySmall?.fontSize,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  items: items.map<DropdownMenuItem<String>>((item) {
                    String key = item.keys.first;
                    String value = item.values.first;
                    return DropdownMenuItem<String>(
                      value: key,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 1,
                          horizontal: 5,
                        ),
                        // decoration: BoxDecoration(
                        //   color:
                        //       key == selectedKey
                        //           ? customTheme.secondaryColor.withOpacity(
                        //              0.05,
                        //           )
                        //           : null,
                        //   borderRadius: BorderRadius.circular(15),
                        // ),
                        child: Text(
                          value,
                          style: TextStyle(
                            color: customTheme.textDefault,
                            fontSize: textTheme.bodySmall?.fontSize,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
