import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';

class SelectedDeptView extends StatefulWidget {
  final Map<int, String> deptIds;
  final Map<int, Map> depts;

  const SelectedDeptView({Key key, this.deptIds, @required this.depts})
      : super(key: key);

  @override
  _SelectedDeptViewState createState() => _SelectedDeptViewState();
}

class _SelectedDeptViewState extends State<SelectedDeptView> {
  Map<int, String> _deptIds = Map();
  Map<int, Map> _depts = Map();

  @override
  void initState() {
    super.initState();
    _deptIds.addAll(widget.deptIds);
    _depts.addAll(widget.depts);
  }

  void _delete(int dept) {
    _deptIds.remove(dept);
    _depts.remove(dept);
    if (mounted) setState(() {});
  }

  void _submit() {
    Navigator.pop(context, {
      "multDeptIds": _deptIds,
      "selectIds": _depts,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ComMomBar(
          title: S.of(context).select,
          elevation: 0.5,
          leadingW: SizedBox(
            width: 0.0,
          ),
          backgroundColor: Colors.white,
          rightDMActions: <Widget>[
            buildSureBtn(
              text: S.of(context).ok,
              textStyle: TextStyles.textF14T2,
              color: AppColors.mainColor,
              onPressed: _submit,
            ),
          ],
        ),
        body: ScrollConfiguration(
          behavior: MyBehavior(),
          child: ListView(
            children: _depts.keys.toList().map((dept) {
              return ListItemView(
                title: _depts[dept]['name'],
                widgetRt1: _depts[dept]['isManage']
                    ? InkWell(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.0,
                            vertical: 5.0,
                          ),
                          child: Icon(
                            Icons.cancel,
                            color: Color(0xFFBCBCBC),
                          ),
                        ),
                        onTap: () => _delete(dept),
                      )
                    : null,
              );
            }).toList(),
            padding: EdgeInsets.symmetric(
              vertical: 10.0,
            ),
          ),
        ),
        backgroundColor: Colors.white);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
