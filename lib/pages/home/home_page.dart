import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/pages/team/friend/my_contacts.dart';
import 'package:cobiz_client/pages/work/work_common.dart';
import 'package:cobiz_client/provider/channel_manager.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/list_row_view.dart';
import 'package:cobiz_client/ui/view/shadow_card_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// 该页面已废弃

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  bool _openSetting = false;
  ChannelManager _channelManager = ChannelManager.getInstance();

  @override
  void initState() {
    super.initState();
    _initListener();
  }

  @override
  void dispose() {
    _cancelListener();
    super.dispose();
  }

  Future<void> _initListener() async {
    if (!mounted) return;
    _channelManager.addListener(_channelListener);
  }

  void _channelListener() {
    if (mounted) {
      setState(() {});
    }
  }

  void _cancelListener() {
    _channelManager.removeListener(_channelListener);
  }

  List<Widget> _body() {
    return [
      _buildCommonCard(_recentItem(), '最近联系人', 1),
      _buildCommonCard(_log(), '日志', 2),
      _buildCommonCard(_approve(), '审批', 3),
      _buildCommonCard(Text('日历'), '日历', 4),
      _buildCommonCard(Text('其他'), '其他', 5),
    ];
  }

  //审批
  Widget _approve() {
    return ListItemView(
      // dense: false,
      haveBorder: false,
      title: '[请假单] 小明提交的请假申请',
      labelWidget: Container(
        child: buildAnnotation(S.of(context).typeOfLeave, '事假'),
        padding: EdgeInsets.only(top: 6.0),
      ),
      widgetRt1: Text(''),
      widgetRt2: Text(
        '12-05 至 12-06 日',
        style: TextStyles.textF12,
      ),
    );
  }

  //最近联系人
  Widget _recentItem() {
    List<ChannelStore> listChannel = [];
    for (var i = 0; i < _channelManager.channels.length; i++) {
      if (_channelManager.channels[i].type == 1) {
        listChannel.add(_channelManager.channels[i]);
      }
      if (listChannel.length >= 5) {
        break;
      }
    }
    return Row(
      children: List.generate(
          listChannel.length,
          (index) => _buildImgTextItem(_channelManager.channels[index],
              len: listChannel.length)),
    );
  }

  //日志
  Widget _log() {
    List logData = [
      'assets/images/work/report_daily.png',
      'assets/images/work/report_week.png',
      'assets/images/work/report_month.png'
    ];
    return Row(
      children: List.generate(
          logData.length, (index) => _buildImgItem(logData[index])),
    );
  }

  Widget _buildCommonCard(Widget child, String title, int type) {
    return ShadowCardView(
      margin: EdgeInsets.only(bottom: 15),
      child: Container(
        width: winWidth(context),
        child: Column(
          children: [
            ListRowView(
              titleWidget: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  type == 3 && !_openSetting ? buildNumtip(9) : Container()
                ],
              ),
              haveBorder: false,
              widgetRt1: _openSetting
                  ? ImageView(img: 'assets/images/work/ic_round_wrong.png')
                  : InkWell(
                      onTap: () {
                        print('跳转$title');
                        switch (type) {
                          case 1:
                            routePush(MyContactPage(true));
                            break;
                          default:
                        }
                      },
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 12.0,
                        ),
                      ),
                    ),
            ),
            IgnorePointer(
              ignoring: _openSetting,
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  //日报 周报 月报
  static Widget _buildImgItem(String data) {
    return Expanded(
        child: InkWell(
            onTap: () => {},
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ImageView(
                        img: data,
                      ),
                    ]))));
  }

  //最近联系人
  static Widget _buildImgTextItem(ChannelStore data, {int len}) {
    if (len == 5) {
      return Expanded(
          child: InkWell(
        onTap: () => {
          if (data.id != null)
            {
              // routePush(SingleChatPage(
              //   userId: data.id,
              //   name: data.name ?? '',
              //   avatar: data.avatar ?? '',
              // ))
            }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ImageView(
                img: cuttingAvatar(data.avatar),
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                '${data.name}',
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.textF12T1,
              )
            ],
          ),
        ),
      ));
    } else {
      return InkWell(
        onTap: () => {
          if (data.id != null)
            {
              // routePush(SingleChatPage(
              //   userId: data.id,
              //   name: data.name ?? '',
              //   avatar: data.avatar ?? '',
              // ))
            }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          width: (ScreenData.width - 60) / 5,
          child: Stack(
            overflow: Overflow.visible,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ImageView(
                    img: cuttingAvatar(data.avatar),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    '${data.name}',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.textF12T1,
                  )
                ],
              ),
              Positioned(
                  right: -9.0,
                  child: data.unread > 0 ? buildMessaged() : Container())
            ],
          ),
        ),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.specialBgGray,
      body: Container(
        margin: EdgeInsets.all(15),
        child: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: _body(),
              ),
            )),
            _openSetting
                ? ShadowCardView(
                    child: Container(
                      height: 90,
                      width: winWidth(context),
                      child:
                          ImageView(img: 'assets/images/work/plus_dotted.png'),
                    ),
                  )
                : Container()
          ],
        ),
      ),
      appBar: ComMomBar(
        automaticallyImplyLeading: false,
        title: S.of(context).commonlyUsed,
        centerTitle: false,
        backgroundColor: AppColors.mainColor,
        mainColor: AppColors.white,
        elevation: 0.5,
        rightDMActions: [
          IconButton(
              icon: _openSetting
                  ? Text(
                      '保存',
                      style: TextStyle(color: AppColors.white),
                    )
                  : ImageIcon(
                      AssetImage('assets/images/mine/setting.png'),
                      color: AppColors.white,
                    ),
              onPressed: () {
                setState(() {
                  _openSetting = !_openSetting;
                });
              })
        ],
      ),
    );
  }
}
