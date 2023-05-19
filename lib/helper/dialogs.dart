import 'package:flutter/material.dart';

class dialogs {
  static void showSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.blue,
      behavior: SnackBarBehavior.floating,
    ));
  }

  static void showProgressBar(BuildContext context) {
    showDialog(context: context, builder: (_)=>Center(child: CircularProgressIndicator()));
  }

}
