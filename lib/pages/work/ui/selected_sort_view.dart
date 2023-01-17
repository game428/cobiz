import 'package:cobiz_client/pages/work/ui/select_multi_member.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';

import '../../../domain/work_domain.dart';

class SelectedSortView extends StatefulWidget {
  final int type; // 1.审批人 2.抄送人 3.执行人 4.参与人
  final List<TempMember> members;
  final String title;
  final int teamId;
  final String teamName;

  const SelectedSortView(
      {Key key,
      @required this.type,
      @required this.members,
      this.title,
      this.teamId,
      this.teamName})
      : super(key: key);

  @override
  _SelectedSortViewState createState() => _SelectedSortViewState();
}

class _SelectedSortViewState extends State<SelectedSortView> {
  List<TempMember> _members = List();
  String _title;

  @override
  void initState() {
    super.initState();
    _members = widget.members;
  }

  void _deleteReceiver(TempMember member) {
    _members.remove(member);
    if (mounted) setState(() {});
  }

  void _selectReceiver() async {
    int max = 20;
    final List<TempMember> result = await routePush(SelectMultiMemberPage(
      title: '${S.of(context).select}${widget.title}',
      total: max,
      teamId: widget.teamId,
      teamName: widget.teamName,
      selectedIds: _members,
    ));
    if (result == null) return;
    _members.clear();
    result.forEach((element) {
      _members.add(element);
    });
    if (mounted) setState(() {});
  }

  void _submit() {
    Navigator.pop(context, _members);
  }

  Widget _buildItem(TempMember member, double imgSize) {
    return Container(
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  buildFilletImage(
                    member.head,
                    imgSize: imgSize,
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Icon(
                    widget.type == 1 ? Icons.navigate_next : Icons.add,
                    size: 18.0,
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                ],
              ),
              Container(
                width: imgSize + 2,
                child: Text(
                  member.name,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.textF10C2,
                ),
              ),
            ],
          ),
          Positioned(
            right: 20.0,
            top: 0.0,
            child: InkWell(
              child: Icon(
                Icons.cancel,
                size: 18.0,
              ),
              onTap: () => _deleteReceiver(member),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    double size = 40.0;
    List<Widget> items = _members.map((member) {
      return _buildItem(member, size);
    }).toList();
    items.add(InkWell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 10.0,
          ),
          ImageView(
            img: 'assets/images/work/plus_dotted.png',
            width: size,
            height: size,
          ),
          Text(
            S.of(context).add,
            style: TextStyles.textF10C2,
          ),
        ],
      ),
      onTap: () => _selectReceiver(),
    ));
    return Wrap(
      runSpacing: 10.0,
      children: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case 1:
        _title = '${_members.length} ${S.of(context).personUnit} ${S.of(context).lineUpToApproval}';
        break;
      case 2:
        _title = '${S.of(context).copyTo} ${_members.length} ${S.of(context).personUnit}';
        break;
      case 3:
        _title = '${S.of(context).executor} ${_members.length} ${S.of(context).personUnit}';
        break;
      case 4:
        _title = '${S.of(context).participants} ${_members.length} ${S.of(context).personUnit}';
        break;
      case 5:
        _title = '${S.of(context).host} ${_members.length} ${S.of(context).personUnit}';
        break;
    }
    return Scaffold(
        appBar: ComMomBar(
          titleW: Center(
            child: Text(
              widget.title ?? '',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
            children: <Widget>[
              buildTextTitle(
                _title,
                fontSize: FontSizes.font_s14,
                bottom: 10.0,
              ),
              _buildContent(),
            ],
            padding: EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 15.0,
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
