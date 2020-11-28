import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void dialogOK(BuildContext context, String content) async {
  await showDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        content: Text(content),
        actions: <Widget>[
          FlatButton.icon(
              icon: Icon(Icons.info),
              onPressed: () {
                Navigator.of(context).pop();
              },
              label: Text('OK'))
        ],
      );
    },
  );
}

void snakeBar(BuildContext context, String content) {
  final snackBar = SnackBar(
    content: Text(content),
    action: SnackBarAction(
      label: 'OK',
      onPressed: () {},
    ),
  );
  Scaffold.of(context).showSnackBar(snackBar);
}
