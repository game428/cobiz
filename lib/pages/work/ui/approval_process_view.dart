import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';

import '../../../domain/work_domain.dart';
import 'approval_ui_view.dart';

class ApprovalProcessView extends StatefulWidget {
  final EdgeInsetsGeometry margin;
  final List<TempMember> approvers;
  final List<TempMember> copies;
  final int teamId;
  final String teamName;

  const ApprovalProcessView({
    Key key,
    this.margin,
    @required this.approvers,
    @required this.copies,
    @required this.teamId,
    @required this.teamName,
  }) : super(key: key);

  @override
  _ApprovalProcessViewState createState() => _ApprovalProcessViewState();
}

class _ApprovalProcessViewState extends State<ApprovalProcessView> {
  @override
  void initState() {
    super.initState();
  }

  Widget _buildApprovalProcess() {
    List<Widget> dots = [
      buildMessaged(
        color: Color(0xFF3E80CA),
        size: 6.0,
      ),
      SizedBox(
        height: 6.0,
      ),
    ];
    for (int i = 0; i < 7; i++) {
      dots.add(buildMessaged(
        color: Color(0xFFD2D2D2),
        size: 4.0,
      ));
      dots.add(SizedBox(
        height: i == 6 ? 6.0 : 4.0,
      ));
    }
    dots.add(buildMessaged(
      color: Color(0xFFD87675),
      size: 6.0,
    ));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 5.0,
            vertical: 25.0,
          ),
          child: Column(
            children: dots,
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              ApprovalItemView(
                type: 1,
                members: widget.approvers,
                teamId: widget.teamId,
                teamName: widget.teamName,
                left: 10.0,
              ),
              SizedBox(
                height: 10.0,
              ),
              ApprovalItemView(
                type: 2,
                members: widget.copies,
                teamId: widget.teamId,
                teamName: widget.teamName,
                left: 10.0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          buildTextTitle(
            S.of(context).approvalWorkflow,
          ),
          SizedBox(
            height: 5.0,
          ),
          _buildApprovalProcess(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
