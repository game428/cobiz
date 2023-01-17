import 'package:flutter/material.dart';

class Loading {
  static dynamic ctx;
  static bool loadingStatus = false;

  static void before({@required context, text}) {
    if (loadingStatus) {
      return;
    }
    ctx = context;
    loadingStatus = true;
    showDialog(
      context: ctx,
      builder: (context) {
        return LoadingDialog(text: text);
      },
    );
  }

  static void complete() {
    if (loadingStatus) {
      loadingStatus = false;
      if (ctx != null) {
        Navigator.of(ctx, rootNavigator: true).pop();
      }
    }
  }
}

class LoadingDialog extends StatelessWidget {
  final String text;

  const LoadingDialog({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
              child: Column(
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    this.text ?? 'Loading…',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
