import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';

import 'apply_leave.dart';

class SelectLeavePage extends StatefulWidget {
  final int teamId;
  final String teamName;

  const SelectLeavePage({Key key, this.teamId, this.teamName})
      : super(key: key);

  @override
  _SelectLeavePageState createState() => _SelectLeavePageState();
}

class _SelectLeavePageState extends State<SelectLeavePage> {
  List types;

  @override
  void initState() {
    super.initState();
  }

  void _openApplyPage(int value) async {
    final bool result = await routePush(ApplyLeavePage(
      value: value,
      types: types,
      teamId: widget.teamId,
      teamName: widget.teamName,
    ));
    Navigator.pop(context, result);
  }

  List<Widget> _buildContent() {
    return types.map((item) {
      return ListItemView(
        titleWidget: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                item['text'],
                style: TextStyles.textF16,
              ),
              flex: 3,
            ),
            SizedBox(width: 5),
            Expanded(
                flex: 7,
                child: Text(
                  item['label'],
                  style: TextStyles.textF16C4,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
          ],
        ),
        widgetRt1: ImageView(
          img: arrowRtImage,
        ),
        onPressed: () => _openApplyPage(item['value']),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (types == null) {
      types = typeList(context);
    }
    return Scaffold(
        appBar: ComMomBar(
          title: S.of(context).leave,
          elevation: 0.5,
        ),
        body: ScrollConfiguration(
          behavior: MyBehavior(),
          child: ListView(
            children: _buildContent(),
          ),
        ),
        backgroundColor: Colors.white);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
