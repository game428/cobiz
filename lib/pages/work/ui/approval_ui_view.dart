import 'package:cobiz_client/pages/work/ui/select_multi_member.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';

import '../../../domain/work_domain.dart';
import 'selected_sort_view.dart';

class ApprovalItemView extends StatefulWidget {
  final List<TempMember> members;
  final int teamId;
  final int type; // 1.审批人， 2.抄送人， 3.执行人, 4.参与人, 5.主持人
  final double left;
  final String teamName;

  const ApprovalItemView(
      {Key key,
      @required this.members,
      this.teamId,
      this.teamName,
      this.type,
      this.left = 0})
      : super(key: key);

  @override
  _ApprovalItemViewState createState() => _ApprovalItemViewState();
}

class _ApprovalItemViewState extends State<ApprovalItemView> {
  List<TempMember> _members;
  String _title;

  @override
  void initState() {
    super.initState();
    _members = widget.members;
  }

  void _deleteReceiver(TempMember member) {
    widget.members.remove(member);
    if (mounted) setState(() {});
  }

  void _selectReceiver() async {
    FocusScope.of(context).requestFocus(FocusNode());
    int max = 20;
    final List<TempMember> result = await routePush(SelectMultiMemberPage(
      title: '${S.of(context).select}$_title',
      total: max,
      teamId: widget.teamId,
      teamName: widget.teamName,
      selectedIds: _members,
    ));
    if (result == null) return;
    if (_members.length < max) {
      _members.clear();
      result.forEach((member) {
        _members.add(member);
      });
    }
    if (mounted) setState(() {});
  }

  void _showAllReceiver() async {
    var res = await routeMaterialPush(SelectedSortView(
      members: _members,
      type: widget.type,
      title: _title,
      teamId: widget.teamId,
      teamName: widget.teamName,
    ));

    if (res != null && mounted) {
      setState(() {});
    }
  }

  Widget _buildItems() {
    double size = 40.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        (_members.length > 2
            ? InkWell(
                child: _buildItem(
                    TempMember(
                        name: S.of(context).viewAll,
                        head: 'assets/images/team/team.png'),
                    size,
                    true),
                onTap: () => _showAllReceiver(),
              )
            : SizedBox(
                width: 0.0,
              )),
        (_members.length == 2
            ? _buildItem(_members.first, size, false)
            : SizedBox(
                width: 0.0,
              )),
        (_members.length > 0
            ? _buildItem(_members.last, size, false)
            : SizedBox(
                width: 0.0,
              )),
        InkWell(
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
        ),
      ],
    );
  }

  Widget _buildItem(TempMember member, double imgSize, bool isAll) {
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
          (isAll
              ? SizedBox(
                  width: 0.0,
                  height: 0.0,
                )
              : Positioned(
                  right: 20.0,
                  top: 0.0,
                  child: InkWell(
                    child: Icon(
                      Icons.cancel,
                      size: 18.0,
                    ),
                    onTap: () => _deleteReceiver(member),
                  ),
                )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case 1:
        _title = S.of(context).approver;
        break;
      case 2:
        _title = S.of(context).notifier;
        break;
      case 3:
        _title = S.of(context).executor;
        break;
      case 4:
        _title = S.of(context).participants;
        break;
      case 5:
        _title = S.of(context).host;
        break;
    }
    return Container(
      padding: EdgeInsets.only(
        left: widget.left,
      ),
      child: Row(
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                _title,
                style: TextStyles.textF16,
              ),
              Text(
                '${_members.length} ${S.of(context).personUnit}',
                style: TextStyles.textF12C4,
              ),
            ],
          ),
          Expanded(
            child: _buildItems(),
          ),
        ],
      ),
    );
  }
}
