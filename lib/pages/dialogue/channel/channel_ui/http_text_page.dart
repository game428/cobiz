import 'dart:convert';

import 'package:cobiz_client/domain/azlistview_domain.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/pages/common/web_view.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/forward_page.dart';
import 'package:cobiz_client/pages/work/ui/work_widget.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HttpTextPage extends StatefulWidget {
  final String url;
  final ChatStore msgStore;
  final int type;
  HttpTextPage(this.url, this.msgStore, this.type, {Key key}) : super(key: key);

  @override
  _HttpTextPageState createState() => _HttpTextPageState();
}

class _HttpTextPageState extends State<HttpTextPage> {
  String _title = '';
  ChatStore _chatStore;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() {
    if (widget.msgStore != null) {
      String msg = widget.msgStore.msg;
      if (strIsJson(msg)) {
        var i = jsonDecode(msg);
        i['text'] = widget.url;
        msg = jsonEncode(i);
      } else {
        msg = widget.url;
      }
      _chatStore = ChatStore(
          widget.msgStore.id,
          widget.msgStore.type,
          widget.msgStore.sender,
          widget.msgStore.receiver,
          widget.msgStore.mtype,
          msg,
          name: widget.msgStore.name,
          avatar: widget.msgStore.avatar,
          state: widget.msgStore.state,
          time: widget.msgStore.time,
          burn: widget.msgStore.burn,
          readTime: widget.msgStore.readTime);
    }
  }

  _actionsHandle(String item) async {
    switch (item) {
      case 'open_by_browser':
        // 网络地址
        if (isNetWorkImg(widget.url)) {
          // 打开微信 'weixin://'
          if (await canLaunch(widget.url)) {
            // ios 直接在Safari里打开
            await launch(widget.url,
                forceSafariVC: Platform.isIOS ? false : null);
          } else {
            showToast(context, S.of(context).cantLanuh(widget.url));
            throw 'Could not launch ${widget.url}';
          }
        }
        break;
      case 'copy':
        Clipboard.setData(ClipboardData(text: widget.url));
        showToast(context, S.of(context).copySuccess);
        break;
      case 'forward':
        if (widget.type == 1) {
          routeMaterialPush(ForwardPage(
            forwardType: 1,
            chatStore: _chatStore,
          )).then((value) {
            if (value != null) {
              if (value is ChannelStore) {
                if (value.type == _chatStore.type) {
                  eventBus.emit(
                      EVENT_HTTP_FORWARD, {'msg': _chatStore, 'value': value});
                }
              }
              if (value is ContactExtendIsSelected) {
                if (_chatStore.type == 1) {
                  eventBus.emit(
                      EVENT_HTTP_FORWARD, {'msg': _chatStore, 'value': value});
                }
              }
            }
            Navigator.pop(context);
          });
        }

        break;
      case 'refresh':
        eventBus.emit('reloadweb', true);
        Navigator.pop(context);
        break;
    }
  }

  _showBottom() {
    BorderRadiusGeometry borderRadius = BorderRadius.only(
      topLeft: Radius.circular(15),
      topRight: Radius.circular(15),
    );
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      builder: (BuildContext bct) {
        return Container(
          padding: EdgeInsets.only(bottom: ScreenData.bottomSafeHeight),
          decoration:
              BoxDecoration(color: Colors.white, borderRadius: borderRadius),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: ScreenData.width,
                alignment: Alignment.center,
                color: greyE6Color,
                padding: EdgeInsets.all(15),
                child: Text(
                    S.of(context).whoProvideUrl(Uri.parse(widget.url).host),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                width: ScreenData.width,
                color: greyE6Color,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.type == 1
                          ? buildItem('assets/images/b_forward.png',
                              S.of(context).sendToF, () {
                              _actionsHandle('forward');
                            }, false,
                              color: Colors.white,
                              textWidth: 10,
                              fontSize: 10,
                              space: 7)
                          : Container(),
                      SizedBox(width: widget.type == 1 ? 15 : 0),
                      buildItem(
                          'assets/images/b_copy.png', S.of(context).copyUrl,
                          () {
                        _actionsHandle('copy');
                      }, false,
                          color: Colors.white,
                          textWidth: 10,
                          fontSize: 10,
                          space: 7),
                      SizedBox(width: 15),
                      buildItem(
                          Platform.isIOS
                              ? 'assets/images/b_browser_ios.png'
                              : 'assets/images/b_browser.png',
                          Platform.isIOS
                              ? S.of(context).openBySafari
                              : S.of(context).openByBrower, () {
                        _actionsHandle('open_by_browser');
                      }, false,
                          color: Colors.white,
                          textWidth: 10,
                          fontSize: 10,
                          space: 7),
                      SizedBox(width: 15),
                      buildItem(
                          'assets/images/b_refresh.png', S.of(context).refresh,
                          () {
                        _actionsHandle('refresh');
                      }, false,
                          color: Colors.white,
                          textWidth: 10,
                          fontSize: 10,
                          space: 7)
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                    width: ScreenData.width,
                    alignment: Alignment.center,
                    color: Colors.white,
                    padding: EdgeInsets.all(15),
                    child: Text(S.of(context).cancelText)),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
        title: _title != null && _title != '' ? _title : widget.url,
        elevation: 0.5,
        rightDMActions: [
          IconButton(icon: Icon(Icons.more_horiz), onPressed: _showBottom)
        ],
      ),
      body: WebViewPage(
        widget.url,
        call: (v) {
          if (mounted) {
            setState(() {
              _title = v;
            });
          }
        },
      ),
    );
  }
}
