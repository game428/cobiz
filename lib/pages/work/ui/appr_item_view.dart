import 'package:cobiz_client/http/res/team_model/work_common_list.dart';
import 'package:cobiz_client/pages/work/workbench/general_approval_details.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/shadow_card_view.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/work.dart' as workApi;

import '../work_common.dart';

// 审批，任务，卡片Item pageType 1:待处理 2：已处理 3：已发起 4：抄送我
class ApprItemView extends StatefulWidget {
  final int teamId;
  final WorkCommonListItem workCommonListItem;
  final int pageType;
  final VoidCallback remove;
  final VoidCallback setChange;
  ApprItemView({
    Key key,
    this.teamId,
    this.workCommonListItem,
    this.pageType,
    this.remove,
    this.setChange,
  }) : super(key: key);

  @override
  _ApprItemViewState createState() => _ApprItemViewState();
}

class _ApprItemViewState extends State<ApprItemView> {
  // 撤回
  void _withdraw() {
    showSureModal(context, S.of(context).confirmCancellation, () async {
      Loading.before(context: context);
      bool modifyRes = await workApi.modifyApprovalState(
        id: widget.workCommonListItem.id,
        teamId: widget.teamId,
        type: 3,
      );
      Loading.complete();
      if (modifyRes == true) {
        widget.setChange();
        if (mounted) {
          setState(() {
            widget.workCommonListItem.state = 3;
          });
        }
      } else {
        showToast(context, S.of(context).tryAgainLater);
      }
    }, promptText: S.of(context).revokeHint);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 15.0,
      ),
      foregroundDecoration: widget.pageType != 1
          ? listBuildBadge(widget.workCommonListItem.state,
              widget.workCommonListItem.type, context)
          : null,
      child: InkWell(
        onTap: () {
          routePush(GeneralApprovalDetails(
            id: widget.workCommonListItem.id,
            teamId: widget.teamId,
            updateState: (result) {
              // result['type'], 1：同意，2：拒绝，3：撤销，4：完成
              switch (widget.pageType) {
                case 1: // 待处理
                  if (result['type'] != null) {
                    widget.remove();
                  }
                  break;
                case 2: // 已处理
                case 3: // 已发起
                  if (result['state'] != widget.workCommonListItem.state) {
                    widget.setChange();
                    if (mounted) {
                      setState(() {
                        widget.workCommonListItem.state = result['state'];
                      });
                    }
                  }
                  break;
                case 4: // 抄送我
                  if (widget.workCommonListItem.read != 1) {
                    widget.setChange();
                    widget.workCommonListItem.read = 1;
                  }
                  if (result['state'] != widget.workCommonListItem.state) {
                    widget.setChange();
                    widget.workCommonListItem.state = result['state'];
                  }
                  if (mounted) {
                    setState(() {});
                  }
                  break;
              }
            },
          ));
        },
        child: ShadowCardView(
          blurRadius: 3.0,
          radius: 5.0,
          padding: EdgeInsets.symmetric(
            vertical: 3.0,
          ),
          child: Column(
            children: <Widget>[
              ListItemView(
                titleWidget: buildTitle(widget.workCommonListItem, context),
                labelWidget: Column(
                    children:
                        switchAnnotation(widget.workCommonListItem, context)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 5.0),
                child: switchDealBtn(
                  widget.workCommonListItem,
                  context,
                  widget.teamId,
                  widget.pageType,
                  onPressed: () {
                    widget.remove();
                  },
                  onRevoke: () {
                    _withdraw();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
