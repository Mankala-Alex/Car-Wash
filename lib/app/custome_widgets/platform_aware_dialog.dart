import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Platform-aware dialog that shows:
/// - Material AlertDialog on Android
/// - Cupertino AlertDialog on iOS
class PlatformAwareDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<PlatformDialogAction> actions;
  final bool barrierDismissible;

  const PlatformAwareDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.barrierDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: actions
            .map((action) => CupertinoDialogAction(
                  onPressed: action.onPressed,
                  isDestructiveAction: action.isDestructive,
                  isDefaultAction: action.isDefault,
                  child: Text(action.label),
                ))
            .toList(),
      );
    }

    // Android Material Dialog
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: actions
          .map((action) => TextButton(
                onPressed: action.onPressed,
                child: Text(action.label),
              ))
          .toList(),
    );
  }
}

/// Model for dialog actions
class PlatformDialogAction {
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;
  final bool isDefault;

  PlatformDialogAction({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
    this.isDefault = false,
  });
}
