import 'package:flutter/material.dart';

void showSnackbarMessageGlobal(String msg, BuildContext context) {
  final snackBar = SnackBar(
    content: Text(msg),
    action: SnackBarAction(
      label: "",
      onPressed: () {},
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
