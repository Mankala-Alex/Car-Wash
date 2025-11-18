
import 'package:flutter/material.dart';


class CustomArrowForward extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? iconColor;
  final double? iconSize;
  const CustomArrowForward(
      {super.key, this.onPressed, this.iconColor, this.iconSize});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: onPressed,
        icon: Icon(
            // Platform.isAndroid ? Icons.arrow_forward :
            Icons.arrow_forward,
            color: iconColor,
            size: iconSize));
  }
}
