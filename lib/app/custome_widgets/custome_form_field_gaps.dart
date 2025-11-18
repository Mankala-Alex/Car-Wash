import 'package:flutter/material.dart';

class CustomeFormVerticalGaps extends StatelessWidget {
  final double height;

  const CustomeFormVerticalGaps({super.key, this.height = 20.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}

class CustomeFormHorizontalGaps extends StatelessWidget {
  final double width;

  const CustomeFormHorizontalGaps({super.key, this.width = 20.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width);
  }
}
