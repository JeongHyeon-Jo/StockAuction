import 'package:auction/route.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void showCustomAlertDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? positiveButtonText,
  Function? onPositiveClick,
  String? negativeButtonText,
  Function? onNegativeClick,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          if (negativeButtonText != null)
            TextButton(
              child: Text(negativeButtonText),
              onPressed: () {
                if (onNegativeClick != null) {
                  print("negative click");
                  onNegativeClick();
                } else {
                  print("negative null click");
                  context.pop();
                }
              },
            ),
          TextButton(
            child: Text(positiveButtonText ?? "확인"),
            onPressed: () {
              if (onPositiveClick != null) {
                print("positive click positive message : $positiveButtonText");
                onPositiveClick();
              } else {
                print("positive button null click");
                context.pop();
              }
            },
          ),
        ],
      );
    },
  );
}
