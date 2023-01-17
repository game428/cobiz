import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActiveSessionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ActiveSessionPagePageState();
  }
}

class _ActiveSessionPagePageState extends State<ActiveSessionPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new ComMomBar(
        title: S.of(context).activeSession,
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
