import 'package:cobiz_client/domain/work_domain.dart';
import 'package:cobiz_client/http/res/team_model/team_info.dart';
import 'package:cobiz_client/http/res/team_model/work_notice.dart';
import 'package:cobiz_client/http/work.dart' as workApi;
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import 'approval/apply_expense.dart';
import 'approval/apply_general.dart';
import 'approval/select_leave.dart';
import 'meeting/meeting_list.dart';
import 'notice/notice_page.dart';
import 'report/work_report.dart';
import 'task/issue_task.dart';
import 'ui/work_widget.dart';
import 'workbench/appre_state.dart';

class WorkPage extends StatefulWidget {
  final TeamInfo teamInfo;

  const WorkPage({Key key, this.teamInfo}) : super(key: key);

  _WorkPageState createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  bool _isLoadOk = false;
  List<Notice> _notices = List();

  bool _haveNewWork = false; //是否有待处理的新工作

  bool _haveNewCopy = false; //是否有新的抄送未读

  bool _haveNewDaily = false; //是否有新的日报

  bool _haveNewMeeting = false; //是否有新的会议纪要

  SwiperController _swiperController = SwiperController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    initNotice();
    _initWork();
    _initDaily();
    _initCopy();
    _initMeeting();
  }

  void initNotice() async {
    List<Notice> list = await workApi.noticeList(teamId: widget.teamInfo.id);
    if (mounted) {
      setState(() {
        if (list != null) {
          _notices = list;
          _isLoadOk = true;
        }
      });
    }
  }

  void _initWork() async {
    List list = await workApi.getApprovalList(
        teamId: widget.teamInfo.id, type: 1, page: 1, size: 1);
    if ((list?.length ?? 0) > 0) {
      if (mounted) {
        setState(() {
          _haveNewWork = true;
        });
      }
    } else if (_haveNewWork) {
      if (mounted) {
        setState(() {
          _haveNewWork = false;
        });
      }
    }
  }

  void _initDaily() async {
    List list = await workApi.getLogList(
        teamId: widget.teamInfo.id, type: 1, page: 1, size: 1);
    if ((list?.length ?? 0) > 0) {
      if (mounted) {
        setState(() {
          _haveNewDaily = true;
        });
      }
    } else if (_haveNewDaily) {
      if (mounted) {
        setState(() {
          _haveNewDaily = false;
        });
      }
    }
  }

  void _initMeeting() async {
    List list = await workApi.getMeetingList(
        teamId: widget.teamInfo.id, type: 1, page: 1, size: 1);
    if ((list?.length ?? 0) > 0) {
      if (mounted) {
        setState(() {
          _haveNewMeeting = true;
        });
      }
    } else if (_haveNewMeeting) {
      if (mounted) {
        setState(() {
          _haveNewMeeting = false;
        });
      }
    }
  }

  void _initCopy() async {
    int count = await workApi.getCopytoCount(teamId: widget.teamInfo.id);
    if (count > 0) {
      if (mounted) {
        setState(() {
          _haveNewCopy = true;
        });
      }
    } else if (_haveNewCopy) {
      if (mounted) {
        setState(() {
          _haveNewCopy = false;
        });
      }
    }
  }

  Widget _swiperBuilder(BuildContext context, int index) {
    return Container(
      height: 30,
      alignment: Alignment.centerLeft,
      child: Text(
        _notices.length > 0 ? _notices[index].title : S.of(context).noNotice,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.textF14C3,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        bottom: 12.0,
        top: 5.0,
      ),
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.elliptical(20.0, 20.0),
        ),
      ),
      child: GestureDetector(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.volume_up,
              color: Colors.white,
            ),
            SizedBox(
              width: 5.0,
            ),
            !_isLoadOk
                ? buildProgressIndicator(size: 30, padding: EdgeInsets.all(0))
                : Expanded(
                    child: _notices.length > 1
                        ? Container(
                            width: ScreenData.width,
                            alignment: Alignment.centerLeft,
                            height: 30,
                            child: Swiper(
                              controller: _swiperController,
                              itemBuilder: _swiperBuilder,
                              itemCount: _notices.length,
                              scrollDirection: Axis.vertical,
                              autoplay: true,
                              autoplayDelay: 5000,
                              onTap: ((index) {
                                routePush(NoticePage(
                                    teamInfo: widget.teamInfo,
                                    updateCall: initNotice));
                              }),
                            ),
                          )
                        : _swiperBuilder(context, 0),
                  ),
          ],
        ),
        onTap: () {
          routePush(
              NoticePage(teamInfo: widget.teamInfo, updateCall: initNotice));
        },
      ),
    );
  }

  void _actionHandle(ApplyTypeValue value) {
    switch (value) {
      case ApplyTypeValue.leave:
        // 请假
        routePush(SelectLeavePage(
          teamId: widget.teamInfo.id,
          teamName: widget.teamInfo.name,
        )).then((value) {
          if (value == true && _haveNewWork == false) {
            _initWork();
          }
        });
        break;
      case ApplyTypeValue.evection:
        // 出差
        break;
      case ApplyTypeValue.general:
        // 通用
        routePush(ApplyGeneralPage(
          teamId: widget.teamInfo.id,
          teamName: widget.teamInfo.name,
        )).then((value) {
          if (value == true && _haveNewWork == false) {
            _initWork();
          }
        });
        break;
      case ApplyTypeValue.expense:
        // 报销
        routePush(ApplyExpensePage(
          teamId: widget.teamInfo.id,
          teamName: widget.teamInfo.name,
        )).then((value) {
          if (value == true && _haveNewWork == false) {
            _initWork();
          }
        });
        break;
      case ApplyTypeValue.log:
        // 写日志
        // routePush(SelectReportPage(
        //   teamId: widget.teamInfo.id,
        //   teamName: widget.teamInfo.name,
        // )).then((value) {
        //   if (_haveNewDaily == false) {
        //     _initDaily();
        //   }
        // });
        break;
      case ApplyTypeValue.logging:
        // 日志记录
        routePush(WorkReportPage(
          teamId: widget.teamInfo.id,
          teamName: widget.teamInfo.name,
        )).then((value) {
          _initDaily();
        });
        break;
      case ApplyTypeValue.meeting:
        // 会议纪要
        routePush(MeetingPage(
          teamId: widget.teamInfo.id,
          teamName: widget.teamInfo.name,
        )).then((value) {
          _initMeeting();
        });
        break;
      case ApplyTypeValue.task:
        // 任务
        routePush(IssueTaskPage(
          teamId: widget.teamInfo.id,
          teamName: widget.teamInfo.name,
        )).then((value) {
          if (value == true && _haveNewWork == false) {
            _initWork();
            _initCopy();
          }
        });
        break;
      case ApplyTypeValue.pending:
        // 待处理
        routePush(AppreStatePage(
          teamId: widget.teamInfo.id,
          title: S.of(context).todo,
          pageType: 1,
          backData: (v) {
            if (v == true) {
              _initWork();
              if (_haveNewCopy == false) {
                _initCopy();
              }
            }
          },
        ));
        break;
      case ApplyTypeValue.processed:
        // 已处理
        routePush(AppreStatePage(
          teamId: widget.teamInfo.id,
          title: S.of(context).done,
          pageType: 2,
        ));
        break;
      case ApplyTypeValue.initiated:
        // 已发起
        routePush(AppreStatePage(
          teamId: widget.teamInfo.id,
          title: S.of(context).initiated,
          pageType: 3,
        ));
        break;
      case ApplyTypeValue.copyMe:
        // 抄送我
        routePush(AppreStatePage(
          teamId: widget.teamInfo.id,
          title: S.of(context).copyMe,
          pageType: 4,
          backData: (v) {
            if (v == true) {
              _initCopy();
            }
          },
        ));
        break;
    }
  }

  Widget _stateTip() {
    List tipList = [
      {
        "icon": 'assets/images/work/pending.png',
        "title": S.of(context).todo,
        "callBack": () => _actionHandle(ApplyTypeValue.pending),
        "isMsg": _haveNewWork,
      },
      {
        "icon": 'assets/images/work/processed.png',
        "title": S.of(context).done,
        "callBack": () => _actionHandle(ApplyTypeValue.processed)
      },
      {
        "icon": 'assets/images/work/initiated.png',
        "title": S.of(context).initiated,
        "callBack": () => _actionHandle(ApplyTypeValue.initiated)
      },
      {
        "icon": 'assets/images/work/copy_me.png',
        "title": S.of(context).copyMe,
        "callBack": () => _actionHandle(ApplyTypeValue.copyMe),
        "isMsg": _haveNewCopy
      },
    ];
    List<Widget> itemList = List();
    tipList.forEach((item) {
      itemList.add(buildTip(
        item['icon'],
        item['title'],
        item['callBack'],
        item['isMsg'] ?? false,
      ));
    });

    return Padding(
      padding:
          EdgeInsets.only(top: 20.0, bottom: 15.0, left: 15.0, right: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: itemList,
      ),
    );
  }

  void _backCall() {
    if (_haveNewWork || _haveNewDaily || _haveNewCopy || _haveNewMeeting) {
      eventBus.emit(EVENT_UPDATE_WORK, widget.teamInfo.id);
    } else {
      eventBus.emit(EVENT_UPDATE_WORK, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    List approval = [
      {
        "icon": 'assets/images/work/general_approval.png',
        "title": S.of(context).universal,
        "callBack": () => _actionHandle(ApplyTypeValue.general)
      },
      {
        "icon": 'assets/images/work/ic_leave.png',
        "title": S.of(context).leave,
        "callBack": () => _actionHandle(ApplyTypeValue.leave)
      },
      {
        "icon": 'assets/images/work/expense.png',
        "title": S.of(context).reimbursement,
        "callBack": () => _actionHandle(ApplyTypeValue.expense)
      }
    ];
    List report = [
      // {
      //   "icon": 'assets/images/work/edit.png',
      //   "title": S.of(context).writeLog,
      //   "callBack": () => _actionHandle(ApplyTypeValue.log)
      // },
      {
        "icon": 'assets/images/work/logList.png',
        "title": S.of(context).logging,
        "callBack": () => _actionHandle(ApplyTypeValue.logging),
        "isMsg": _haveNewDaily,
      },
      {
        "icon": 'assets/images/work/meeting.png',
        "title": S.of(context).meeting,
        "callBack": () => _actionHandle(ApplyTypeValue.meeting),
        "isMsg": _haveNewMeeting,
      }
    ];  
    List task = [
      {
        "icon": 'assets/images/work/task.png',
        "title": S.of(context).task,
        "callBack": () => _actionHandle(ApplyTypeValue.task)
      }
    ];
    return Scaffold(
        appBar: ComMomBar(
          title: widget.teamInfo.name,
          mainColor: AppColors.white,
          backCall: _backCall,
          backgroundColor: AppColors.mainColor,
        ),
        body: ScrollConfiguration(
          behavior: MyBehavior(),
          child: Column(
            children: <Widget>[
              _buildHeader(),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    _stateTip(),
                    Container(
                      height: 8.0,
                      margin: EdgeInsets.only(bottom: 20.0),
                      color: AppColors.specialBgGray,
                    ),
                    buildWork(approval, S.of(context).oaApproval),
                    buildWork(task, S.of(context).issueTask),
                    buildWork(report, S.of(context).dailyRecord),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white);
  }

  @override
  void dispose() {
    _swiperController?.dispose();
    super.dispose();
  }
}
