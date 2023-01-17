import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_img_msg.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_person_card.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_play_voice.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_video_msg.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/http_text_page.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/white_text_detail.dart';
import 'package:cobiz_client/pages/dialogue/channel/group_chat/group_avatar.dart';
import 'package:cobiz_client/pages/work/ui/img_view_save.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/date_util.dart';
import 'package:cobiz_client/ui/special_text/my_special_text_builder.dart';
import 'package:cobiz_client/ui/view/shadow_card_view.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'chat_notice_msg.dart';

class ChatMsgShow {
  //消息头像 展示
  static Widget channelAvatar(ChannelStore channel) {
    Widget iconWidget;
    switch (channel.type) {
      case 1:
        iconWidget = ImageView(
          img: cuttingAvatar(channel.avatar),
          width: 42.0,
          height: 42.0,
          needLoad: true,
          isRadius: 21.0,
          fit: BoxFit.cover,
        );
        break;
      case 2:
        iconWidget = GroupAvatar(jsonDecode(channel.avatar), channel.name,
            jsonDecode(channel.avatar).length, channel.gType ?? 0);
        break;
      case 3:
        iconWidget = Container(
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusDirectional.circular(21.0),
              side: BorderSide(color: Colors.grey, width: 0.3),
            ),
            color: blueDEColor,
          ),
          alignment: Alignment.center,
          width: 40.0,
          height: 40.0,
          child: ImageView(
            width: 20,
            height: 20,
            img: 'assets/images/team/work.png',
          ),
        );
        break;
      default:
        iconWidget = ImageView(
          img: cuttingAvatar(''),
          width: 42.0,
          height: 42.0,
          needLoad: true,
          isRadius: 21.0,
          fit: BoxFit.cover,
        );
    }
    return iconWidget;
  }

  //群聊区分
  static Widget groupWidget(ChannelStore channel) {
    Widget _widget = Container();
    if (channel.type == 2) {
      switch (channel.gType ?? 0) {
        case 1:
          _widget =
              ImageView(img: 'assets/images/org2.png', width: 18, height: 18);
          break;
        case 2:
        case 3:
          _widget =
              ImageView(img: 'assets/images/tg.png', width: 18, height: 18);
          break;
        default:
          _widget = Container();
      }
    }
    return _widget;
  }

  //群聊区分2
  static Widget groupWidget2(int gType) {
    Widget _widget = Container();
    switch (gType) {
      case 1:
        _widget =
            ImageView(img: 'assets/images/org2.png', width: 18, height: 18);
        break;
      case 2:
      case 3:
        _widget = ImageView(img: 'assets/images/tg.png', width: 18, height: 18);
        break;
      default:
        _widget = Container();
    }
    return _widget;
  }

  //消息 label 展示
  static Widget labelWidget(BuildContext context, ChannelStore channel) {
    var data = jsonDecode(channel.label);
    bool isAtMe = false;
    if (data['atMe'] == true && channel.type == 2) {
      isAtMe = true;
    }

    if (isAtMe == true && (channel.unread ?? 0) > 0) {
      return RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
              text: '[${S.of(context).hasAtMe}] ',
              style: TextStyle(color: Colors.red, fontSize: 12),
              children: [
                TextSpan(
                    text: _labelDeal(context, channel).trim(),
                    style: TextStyle(fontSize: 12, color: grey81Color))
              ]));
    } else {
      return Text(
        _labelDeal(context, channel).trim(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12),
      );
    }
  }

  // label
  static String _labelDeal(BuildContext context, ChannelStore channel) {
    var data = jsonDecode(channel.label);
    ChatStore labelData;
    if (channel.type == 2 && data['atMe'] == true) {
      labelData = ChatStore.fromJsonMap(jsonDecode(data['text']));
    } else {
      labelData = ChatStore.fromJsonMap(data);
    }
    String label = '';
    switch (labelData.mtype) {
      case 1:
        if (channel.type == 2 && labelData.type == 2) {
          if (strNoEmpty(jsonDecode(labelData.msg)['text'])) {
            label =
                '${labelData.name}${labelData.name == '' ? '' : '：'}${jsonDecode(labelData.msg)['text']}';
          } else {
            label = '';
          }
        } else {
          if (strIsJson(labelData.msg)) {
            label = jsonDecode(labelData.msg)['text'];
          } else {
            label = labelData.msg;
          }
        }
        break;
      case 2:
        if (channel.type == 2 && labelData.type == 2) {
          label = '${labelData.name}：[${S.of(context).audio}]';
        } else {
          label = '[${S.of(context).audio}]';
        }
        break;
      case 3:
        if (channel.type == 2 && labelData.type == 2) {
          label = '${labelData.name}：[${S.of(context).photo}]';
        } else {
          label = '[${S.of(context).photo}]';
        }
        break;
      case 4:
        if (channel.type == 2 && labelData.type == 2) {
          label = '${labelData.name}：[${S.of(context).video}]';
        } else {
          label = '[${S.of(context).video}]';
        }
        break;
      case 5:
        if (channel.type == 2 && labelData.type == 2) {
          label = '${labelData.name}：[${S.of(context).contactCard}]';
        } else {
          label = '[${S.of(context).contactCard}]';
        }
        break;
      case 8:
        label = S.of(context).teamNotice(labelData.name);
        break;
      case 9:
        if (strIsJson(labelData.msg)) {
          Map labelDataMap = jsonDecode(labelData.msg);
          if (labelDataMap['mode'] == 1) {
            if (labelDataMap['type'] == 4) {
              if (strNoEmpty(labelDataMap['reviewer'])) {
                label =
                    '[${S.of(context).task}] ${S.of(context).someRevTask(labelDataMap['reviewer'], labelDataMap['name'])}';
              } else {
                label =
                    '[${S.of(context).task}] ${S.of(context).taskTitle(labelDataMap['name'] ?? '')}';
              }
            } else {
              if (strNoEmpty(labelDataMap['reviewer'])) {
                label =
                    '[${S.of(context).approve}] ${S.of(context).someRevAppr(labelDataMap['reviewer'], labelDataMap['name'])}';
              } else {
                label =
                    '[${S.of(context).approve}] ${S.of(context).needU(labelDataMap['name'] ?? '')}';
              }
            }
          } else if (labelDataMap['mode'] == 2) {
            if (strNoEmpty(labelDataMap['reviewer'])) {
              label =
                  '[${S.of(context).logging}] ${S.of(context).someRev(labelDataMap['reviewer'], labelDataMap['name'])}';
            } else {
              label =
                  '[${S.of(context).logging}] ${S.of(context).upLog(labelDataMap['name'] ?? '')}';
            }
          } else if (labelDataMap['mode'] == 3) {
            if (strNoEmpty(labelDataMap['reviewer'])) {
              label =
                  '[${S.of(context).meeting}] ${S.of(context).someRevMeeting(labelDataMap['reviewer'], labelDataMap['name'])}';
            } else {
              label =
                  '[${S.of(context).meeting}] ${S.of(context).meetingMinTitle(labelDataMap['name'] ?? '')}';
            }
          }
        }
        break;
      case 101:
        if (labelData.sender == API.userInfo.id) {
          label = S
              .of(context)
              .invitedThem(json.decode(labelData.msg)['names'].join('、'));
        } else if (json
            .decode(labelData.msg)['ids']
            .contains(API.userInfo.id)) {
          label = '${labelData.name} ${S.of(context).inviteMeToGroupChat}';
        } else {
          label = S.of(context).whoInvitedThem(
              labelData.name, json.decode(labelData.msg)['names'].join('、'));
        }
        break;
      case 102:
        label = S.of(context).leftTheGroup(labelData.name);
        break;
      case 105:
        label = S.of(context).issuedNewNotice;
        break;
      case 106:
        label = S.of(context).blockedTip;
        break;
      case 108:
        label = '[${S.of(context).teamInvitation}]';
        break;
      case 201:
        label = S.of(context).addedContactToChat(labelData.msg);
        break;
      case 301:
        label = '[${S.of(context).draft}] ${jsonDecode(labelData.msg)['text']}';
        break;
      default:
    }
    return label;
  }

  // 转发消息展示
  static Widget buildMsg(BuildContext context, ChatStore chatStore) {
    switch (chatStore.mtype) {
      case 1: //文本
        String text = '';
        if (chatStore.type == 1) {
          if (strIsJson(chatStore.msg)) {
            text = jsonDecode(chatStore.msg)['text'];
          } else {
            text = chatStore.msg;
          }
        } else {
          text = jsonDecode(chatStore.msg)['text'];
        }
        return Container(
          constraints: BoxConstraints(
              minHeight: 30.0,
              minWidth: 40.0,
              maxWidth: winWidth(context) * 0.7),
          padding: EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          child: Text(text ?? '',
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black,
              )),
        );
        break;
      case 3: //图片
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(0.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            child: Container(
              constraints: BoxConstraints(maxHeight: 160.0),
              child: ImageView(
                img: chatThumbnail(chatStore.msg),
                width: 120,
                fit: BoxFit.cover,
                defType: 3,
                needLoad: true,
              ),
            ),
          ),
        );
        break;
      case 4: //视频
        return Container(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              child: Container(
                constraints: BoxConstraints(maxHeight: 160.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ImageView(
                      width: 120,
                      // height: 50,
                      img: '${chatStore.msg}?vframe/png/offset/0/w/120',
                      fit: BoxFit.cover,
                      needLoad: true,
                    ),
                    Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 50,
                    )
                  ],
                ),
              ),
            ));
        break;
      default:
        return Container();
    }
  }

  // 当前版本不支持消息类型(default)
  static Widget notSupport(
      BuildContext context, bool isSelf, ChatStore chat, bool isShowRadio) {
    return Stack(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(
            minHeight: 30.0,
            minWidth: 40.0,
            maxWidth: winWidth(context) * (isShowRadio == true ? 0.5 : 0.7),
          ),
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 7),
          decoration: BoxDecoration(
            color: isSelf ? themeColor : AppColors.white,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                S.of(context).notSupportThisMsg,
                style: isSelf
                    ? TextStyle(
                        color: Colors.white,
                      )
                    : null,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 3, right: 5),
                    child: Text(
                      DateUtil.formatTimeForRead(
                          DateUtil.parseIntToTime(chat.time)),
                      style: TextStyle(
                          fontSize: 10,
                          color: isSelf
                              ? Color.fromRGBO(223, 235, 253, 1)
                              : Colors.black),
                    ),
                  ),
                  _isRead(context, isSelf, chat.state, chat.type)
                ],
              ),
            ],
          ),
        ),
        // selfW(isSelf)
      ],
    );
  }

  // 邀请进群推送(101)
  static Widget addGroup(BuildContext context, ChatStore chat) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 15.0,
      ),
      child: Text(
        S.of(context).whoInvitedThem(
            chat.sender == API.userInfo.id ? S.of(context).me : chat.name,
            json.decode(chat.msg)['names'].join('、')),
        style: TextStyles.textF12T5,
        textAlign: TextAlign.center,
      ),
    );
  }

  // 退群推送(102)
  static Widget leaveGroup(BuildContext context, ChatStore chat) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 15.0,
      ),
      child: Text(
        S.of(context).leftTheGroup(chat.name),
        style: TextStyles.textF12T5,
        textAlign: TextAlign.center,
      ),
    );
  }

  // 群公告(105)
  static Widget groupNotice(BuildContext context, ChatStore chat) {
    return ShadowCardView(
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.fromLTRB(6, 0, 6, 15),
      child: Container(
        constraints: BoxConstraints(
          minHeight: 30.0,
          minWidth: 40.0,
        ),
        padding: EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                  width: 5,
                ),
                ImageView(
                  img: 'assets/images/chat/ic_speaker.png',
                  height: 20,
                  width: 20,
                ),
                Text(' ' + S.of(context).groupAnnouncement),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    '${DateUtil.formatSeconds(chat.time, format: 'yyyy-MM-dd HH:mm')}',
                    style: TextStyle(fontSize: 12, color: greyA3Color),
                    textAlign: TextAlign.end,
                  ),
                )),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                chat.msg,
                style: TextStyles.textF14T4,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  // 拉黑推送(106)
  static Widget blockW(ChatStore chat) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 15.0,
      ),
      child: Text(
        chat.msg,
        style: TextStyles.textF12T5,
        textAlign: TextAlign.center,
      ),
    );
  }

  // 加好友推送(201)
  static Widget addFriend(BuildContext context, ChatStore chat) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 15.0,
      ),
      child: Text(
        S.of(context).addedContactToChat(chat.msg),
        style: TextStyles.textF12T5,
        textAlign: TextAlign.center,
      ),
    );
  }

  //语音消息
  static Widget voiceMsg(BuildContext context, bool isSelf, ChatStore chat,
      AudioPlayer audioPlayer, bool isShowRadio) {
    return ChatPlayVoice(
        isSelf,
        chat,
        _isRead(context, isSelf, chat.state, chat.type),
        audioPlayer,
        isShowRadio);
  }

  //个人名片
  static Widget peopleCardMsg(
      BuildContext context, bool isSelf, ChatStore chat) {
    return Stack(
      children: [ChatPersonCard(isSelf, chat), msgTime(context, chat, isSelf)],
    );
  }

  //团队邀请
  static Widget inviteJoinTeam(
      BuildContext context, bool isSelf, ChatStore chat) {
    String avatar = jsonDecode(chat.msg)['tAvatar'];
    return Stack(
      children: [
        ShadowCardView(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
          child: Container(
            constraints: BoxConstraints(
                minHeight: 30.0,
                minWidth: 40.0,
                maxWidth: winWidth(context) * 0.5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListItemView(
                  paddingLeft: 5,
                  paddingRight: 5,
                  color: Colors.transparent,
                  iconWidget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ImageView(
                        img: cuttingAvatar(
                            strNoEmpty(avatar) ? avatar : logoImageG),
                        width: 42.0,
                        height: 42.0,
                        needLoad: true,
                        isRadius: 21.0,
                        fit: BoxFit.cover,
                      )
                    ],
                  ),
                  titleWidget: Text(
                    '${S.of(context).teamJoinTypeInvite}${jsonDecode(chat.msg)['tName']}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '[${S.of(context).teamInvite}]',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                )
              ],
            ),
          ),
        ),
        msgTime(context, chat, isSelf)
      ],
    );
  }

  //团队公告
  static Widget noticeMsg(ChatStore chat) {
    return ChatNotice(chat);
  }

  //图片消息
  static Widget imgMsg(BuildContext context, bool isSelf, ChatStore chat,
      String tempImg, List<dynamic> imgList,
      {Function(dynamic) call}) {
    return Stack(
      children: [
        ChatImgMsg(
          isSelf: isSelf,
          chatStore: chat,
          tempImg: tempImg,
          imgList: imgList,
          callValue: (v) {
            if (v != null) {
              call(v);
            }
          },
        ),
        msgTime(context, chat, isSelf)
      ],
    );
  }

  //视频消息
  static Widget videoMsg(
    BuildContext context,
    bool isSelf,
    ChatStore chat,
  ) {
    return Stack(
      children: [
        ChatVideoMsg(
          chatStore: chat,
        ),
        msgTime(context, chat, isSelf)
      ],
    );
  }

  //引用消息
  static Widget quoteTextMsg(
    ChatStore chatStore,
    BuildContext context,
  ) {
    ///文本消息是否引用
    bool isQuote = false;
    String quoteMsg = '';
    String quoteName = '';
    int mType;
    // int uid;
    // int mid;
    if (chatStore.mtype == 1) {
      if (strIsJson(chatStore.msg)) {
        Map msgMap = jsonDecode(chatStore.msg);
        if (msgMap['quoteName'] != null &&
            msgMap['quoteMsg'] != null &&
            msgMap['quoteMType'] != null &&
            msgMap['quoteUid'] != null &&
            msgMap['quoteMsgId'] != null) {
          quoteName = msgMap['quoteName'];
          quoteMsg = msgMap['quoteMsg'];
          mType = msgMap['quoteMType'];
          // uid = msgMap['quoteUid'];
          // mid = msgMap['quoteMsgId'];
          isQuote = true;
        }
      }
    }
    if (isQuote == true && mType != null) {
      switch (mType) {
        case 1:
          return InkWell(
            onTap: () {
              if (strNoEmpty(quoteMsg)) {
                routeMaterialPush(WhiteTextDetailPage(quoteMsg));
              }
            },
            child: Container(
                child: Text(
                  '$quoteName：$quoteMsg',
                  style: TextStyle(
                      color: Color.fromRGBO(123, 123, 123, 1), fontSize: 12),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                margin: EdgeInsets.only(top: 5),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                constraints: BoxConstraints(
                    minWidth: 40.0, maxWidth: winWidth(context) * 0.5),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(235, 235, 235, 1),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                )),
          );
          break;
        case 3:
          return InkWell(
            onTap: () {
              if (isNetWorkImg(quoteMsg)) {
                routeMaterialPush(ImgViewSavePage(
                  imgList: [quoteMsg],
                  currentUrl: quoteMsg,
                ));
              }
            },
            child: Container(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$quoteName：',
                      style: TextStyle(
                          color: Color.fromRGBO(123, 123, 123, 1),
                          fontSize: 12),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    ImageView(
                        width: 18,
                        height: 18,
                        img: chatThumbnail(quoteMsg),
                        defType: 3,
                        fit: BoxFit.cover,
                        needLoad: true)
                  ],
                ),
                margin: EdgeInsets.only(top: 5),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                constraints: BoxConstraints(
                    minWidth: 40.0, maxWidth: winWidth(context) * 0.5),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(235, 235, 235, 1),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                )),
          );
          break;
        default:
          return Container();
      }
    } else {
      return Container();
    }
  }

  //跳转内部网页 1:有转发 2:无转发
  static void httpLis(String v, ChatStore chatStore, int type) {
    if ((v.toString().startsWith('http://') ||
        v.toString().startsWith('https://'))) {
      routePush(HttpTextPage(v.toString().trim(), chatStore, type));
    }
  }

  //文本消息
  static Widget textMsg(
      BuildContext context, bool isMe, ChatStore msgStore, bool isShowRadio) {
    String msg = '';

    if (msgStore.type == 1) {
      if (strIsJson(msgStore.msg)) {
        msg = jsonDecode(msgStore.msg)['text'];
      } else {
        msg = msgStore.msg;
      }
    } else {
      msg = jsonDecode(msgStore.msg)['text'];
    }

    //检测加不加空格
    msg = httpAddSpace(msg);

    double size = 0;
    for (int i = 0; i < msg.length; i++) {
      if (RegExp(r"[\u4e00-\u9fa5]").hasMatch(msg[i])) {
        size += 1;
      } else {
        size += 0.5;
      }
      if (size >= 12) {
        break;
      }
    }
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Container(
          constraints: BoxConstraints(
              minHeight: 30.0,
              minWidth: 40.0,
              maxWidth: winWidth(context) * (isShowRadio == true ? 0.5 : 0.7)),
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 7),
          decoration: BoxDecoration(
            color: isMe ? AppColors.mainColor : AppColors.white,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          child: size >= 12
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ExtendedText(
                      msg ?? '',
                      style: isMe
                          ? TextStyle(
                              color: Colors.white,
                            )
                          : null,
                      specialTextSpanBuilder: MySpecialTextSpanBuilder(httpBg: isMe),
                      onSpecialTextTap: (dynamic value) {
                        httpLis(value, msgStore, 1);
                      },
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 5, top: 3),
                          child: Text(
                            DateUtil.formatTimeForRead(
                                DateUtil.parseIntToTime(msgStore.time)),
                            style: TextStyle(
                                fontSize: 10,
                                color: isMe ? AppColors.white : Colors.black),
                          ),
                        ),
                        _isRead(context, isMe, msgStore.state, msgStore.type)
                      ],
                    )
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                        child: ExtendedText(
                      msg ?? '',
                      style: isMe ? TextStyle(color: Colors.white) : null,
                      specialTextSpanBuilder: MySpecialTextSpanBuilder(httpBg: isMe),
                      onSpecialTextTap: (dynamic value) {
                        httpLis(value, msgStore, 1);
                      },
                    )),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10, right: 5),
                          child: Text(
                            DateUtil.formatTimeForRead(
                                DateUtil.parseIntToTime(msgStore.time)),
                            style: TextStyle(
                                fontSize: 10,
                                color: isMe ? AppColors.white : Colors.black),
                          ),
                        ),
                        _isRead(context, isMe, msgStore.state, msgStore.type)
                      ],
                    )
                  ],
                ),
        ),
        selfW(isMe)
      ],
    );
  }

  //角标
  static Widget selfW(bool isSelf) {
    return isSelf
        ? Positioned(
            top: 5.0,
            right: -7.0,
            child: ImageView(
              img: 'assets/images/chat/ic_cusp1.png',
            ),
          )
        : Positioned(
            top: 5.0,
            left: -7.0,
            child: ImageView(
              img: 'assets/images/chat/ic_cusp2.png',
            ),
          );
  }

  // 时间下标定位
  static Widget msgTime(BuildContext context, ChatStore chatStore, bool isMe,
      {double bottom = 5, double right = 5}) {
    return Positioned(
      bottom: bottom,
      right: right,
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                DateUtil.formatTimeForRead(DateUtil.parseIntToTime(
                    chatStore.time ?? DateTime.now().millisecondsSinceEpoch)),
                style: TextStyle(color: Colors.white, fontSize: 10)),
            SizedBox(
              width: (isMe &&
                      (chatStore.state == 1 || chatStore.state == 2) &&
                      chatStore.type == 1)
                  ? 5
                  : 0,
            ),
            _isRead(context, isMe, chatStore.state, chatStore.type)
          ],
        ),
        padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(5)),
      ),
    );
  }

  //是否已读
  static Widget _isRead(
      BuildContext context, bool isMe, int state, int chatType) {
    if (isMe && chatType == 1) {
      if (state == 1) {
        return Icon(
          Icons.done,
          size: 17,
          color: AppColors.white,
        );
      } else if (state == 2) {
        return Icon(
          Icons.done_all,
          size: 17,
          color: AppColors.white,
        );
      } else {
        return Container(
          height: 17,
        );
      }
    } else {
      return Container(
        height: 17,
      );
    }
  }
}
