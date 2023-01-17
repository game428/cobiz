import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_msg_show.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/date_util.dart';
import 'package:cobiz_client/ui/view/voice_animation_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/storage_utils.dart' as localStorage;

class ChatPlayVoice extends StatefulWidget {
  final bool isSelf;
  final ChatStore chat;
  final Widget mark;
  final AudioPlayer _audioPlayer;
  final bool isShowRadio;
  ChatPlayVoice(
      this.isSelf, this.chat, this.mark, this._audioPlayer, this.isShowRadio,
      {Key key})
      : super(key: key);

  @override
  _ChatPlayVoiceState createState() => _ChatPlayVoiceState();
}

class _ChatPlayVoiceState extends State<ChatPlayVoice> {
  bool isPlayVoice = false; //是否播放
  bool isLoading = false; //是否加载
  List voiceImgs = [];
  @override
  void initState() {
    super.initState();
    eventBus.on(EVENT_VOICE_ONLISTEN, _playListen);
  }

  _playListen(arg) {
    if (arg != null) {
      switch (arg['type']) {
        case 'autoplay': // 自动播放
          if (arg['mId'] == widget.chat.id && !isLoading && !isPlayVoice) {
            _play();
          }
          if (mounted &&
              arg['mId'] != widget.chat.id &&
              (isLoading || isPlayVoice)) {
            setState(() {
              isPlayVoice = false;
              isLoading = false;
            });
          }
          break;
        case 'onPlayerStateChanged': // 状态切换
          if (mounted && (isPlayVoice || isLoading)) {
            setState(() {
              isPlayVoice = false;
              isLoading = false;
            });
          }
          break;
        case 'onAudioPositionChanged': // 音频文件是否已经加载完毕（IOS）
          if (mounted && !isPlayVoice && isLoading) {
            setState(() {
              isLoading = false;
              isPlayVoice = true;
            });
          }
          break;
        case 'onDurationChanged': // 音频文件是否已经加载完毕（android）
          if (mounted && !isPlayVoice && isLoading) {
            setState(() {
              isLoading = false;
              isPlayVoice = true;
            });
          }
          break;
        default:
      }
    }
  }

  var leftImgs = [
    'assets/images/chat/sound_left_3.png',
    'assets/images/chat/sound_left_1.png',
    'assets/images/chat/sound_left_2.png',
    'assets/images/chat/sound_left_3.png',
  ];

  var rightImgs = [
    'assets/images/chat/sound_right_3.png',
    'assets/images/chat/sound_right_1.png',
    'assets/images/chat/sound_right_2.png',
    'assets/images/chat/sound_right_3.png',
  ];

  ///播放后标识已读 更新缓存
  _readedVoice() async {
    if (!widget.isSelf && widget.chat.isReadVoice == false) {
      widget.chat.isReadVoice = true;
      await localStorage.voiceReadLocalChat(
          widget.chat.type,
          widget.chat.type == 1 ? widget.chat.sender : widget.chat.receiver,
          widget.chat.id);
    }
  }

  ///播放
  _play() async {
    await _readedVoice();
    String url = jsonDecode(widget.chat.msg)['path'];
    if (url != null && url != '') {
      widget._audioPlayer.stop();
      int res = await widget._audioPlayer.play(url);
      if (res == 1) {
        if (mounted) {
          setState(() {
            // isPlayVoice = true;
            isLoading = true;
          });
        }
      } else {
        print('error');
      }
    }
  }

  @override
  void deactivate() async {
    try {
      int res = await widget._audioPlayer.release();
      if (res == 1) {
        // print('release ok');
      } else {
        // print('release failed');
      }
    } catch (e) {
      // skip
    }
    super.deactivate();
  }

  @override
  void dispose() {
    eventBus.off(EVENT_VOICE_ONLISTEN, _playListen);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSelf == true) {
      voiceImgs = rightImgs;
    } else {
      voiceImgs = leftImgs;
    }
    double minWidth = 0.0;

    if (widget.isShowRadio == true) {
      minWidth = 0.0;
    } else {
      minWidth = 90 +
          (winWidth(context) * 0.7 - 90) *
              (jsonDecode(widget.chat.msg)['secoonds'] ?? 0) /
              60;
      if (minWidth >= winWidth(context) * 0.7) {
        minWidth = winWidth(context) * 0.7 - 1;
      }
    }

    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        InkWell(
          highlightColor: Colors.white.withOpacity(0),
          splashColor: Colors.white.withOpacity(0),
          onTap: () async {
            eventBus.emit(EVENT_VOICE_ONTOUCH, {
              'type': 'sendTouch',
              'path': jsonDecode(widget.chat.msg)['path'],
              'mId': widget.chat.id,
              'autoplay': widget.chat.isReadVoice == true ? false : true
            });
            if (!isPlayVoice) {
              if (widget._audioPlayer.state == AudioPlayerState.PLAYING) {
                await widget._audioPlayer.stop();
              }
              _play();
            } else {
              widget._audioPlayer.stop();
            }
          },
          child: Container(
            constraints: BoxConstraints(
                minHeight: 30.0,
                minWidth: minWidth,
                maxWidth: winWidth(context) * 0.7),
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 7),
            decoration: BoxDecoration(
              color: widget.isSelf ? AppColors.mainColor : AppColors.white,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: widget.isSelf
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${jsonDecode(widget.chat.msg)['secoonds']}"',
                            style: TextStyles.textF14T2,
                          ),
                          SizedBox(width: 5),
                          isLoading
                              ? ImageView(
                                  img: 'assets/images/chat/ic_load_white.gif',
                                  height: 20,
                                  width: 20,
                                )
                              : !isPlayVoice
                                  ? ImageView(
                                      img:
                                          'assets/images/chat/sound_right_3.png',
                                      height: 20,
                                      width: 20,
                                    )
                                  : VoiceAnimationImage(
                                      voiceImgs,
                                      width: 20,
                                      height: 20,
                                      isStop: isPlayVoice,
                                    ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 10, right: 5),
                            child: Text(
                              DateUtil.formatTimeForRead(
                                  DateUtil.parseIntToTime(widget.chat.time)),
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.white),
                            ),
                          ),
                          widget.mark
                        ],
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          isLoading
                              ? ImageView(
                                  img: 'assets/images/chat/ic_load_green.gif',
                                  height: 20,
                                  width: 20,
                                )
                              : !isPlayVoice
                                  ? ImageView(
                                      img:
                                          'assets/images/chat/sound_left_3.png',
                                      height: 20,
                                      width: 20,
                                    )
                                  : VoiceAnimationImage(
                                      voiceImgs,
                                      width: 20,
                                      height: 20,
                                      isStop: isPlayVoice,
                                    ),
                          SizedBox(width: 5),
                          Text(
                            '${jsonDecode(widget.chat.msg)['secoonds']}"',
                            style: TextStyles.textF14,
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          DateUtil.formatTimeForRead(
                              DateUtil.parseIntToTime(widget.chat.time)),
                          style: TextStyle(fontSize: 10, color: Colors.black),
                        ),
                      )
                    ],
                  ),
          ),
        ),
        !widget.isSelf && widget.chat.isReadVoice == false
            ? Positioned(
                top: 5.0,
                right: -10.0,
                child: buildMessaged(size: 6),
              )
            : Container(),
        ChatMsgShow.selfW(widget.isSelf)
      ],
    );
  }
}
