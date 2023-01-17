import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoInternetHint extends StatelessWidget {
  const NoInternetHint({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(title: S.of(context).noInternet, elevation: 0.5),
      body: Container(
        width: winWidth(context),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).noInternet1,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(S.of(context).noInternet2),
            SizedBox(height: 15),
            RichText(
                text: TextSpan(
              text: S.of(context).noInternet3,
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                    text: S.of(context).noInternet4,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                TextSpan(text: S.of(context).noInternet5)
              ],
            )),
            RichText(
                text: TextSpan(
              text: S.of(context).noInternet3,
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                    text: S.of(context).noInternet6,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                TextSpan(text: S.of(context).noInternet7)
              ],
            )),
            SizedBox(height: 30),
            Text(S.of(context).noInternet8),
            SizedBox(height: 15),
            Text(S.of(context).noInternet9),
            SizedBox(height: 30),
            Text(
              S.of(context).noInternet10,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
