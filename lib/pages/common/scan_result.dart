import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScanResultPage extends StatelessWidget {
  final String comment;
  const ScanResultPage(this.comment, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
        title: S.of(context).scanRes,
        elevation: 0.5,
        rightDMActions: [
          IconButton(
              icon: Icon(Icons.content_copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: comment ?? ''));
                showToast(context, S.of(context).copySuccess);
              })
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.all(15),
          width: winWidth(context),
          child: Text(
            comment ?? "",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
