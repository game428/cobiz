import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TwoStepVerificationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TwoStepVerificationPageState();
  }
}

class _TwoStepVerificationPageState extends State<TwoStepVerificationPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new ComMomBar(
        title: S.of(context).twoStepVerification,
        elevation: 0.5,
      ),
      body: Container(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
