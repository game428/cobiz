import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatRecordingVoice extends StatefulWidget {
  final Function(Map) call;
  ChatRecordingVoice(this.call, {Key key}) : super(key: key);

  @override
  _ChatRecordingVoiceState createState() => _ChatRecordingVoiceState();
}

class _ChatRecordingVoiceState extends State<ChatRecordingVoice> {
  bool _voiceState = false;
  String _voiceTextShow = '';
  bool _isVoiceUp = false;
  double _startY = 0.0;
  double _offset = 0.0;
  OverlayEntry overlayEntry;
  String path;
  Codec _codec = Codec.aacADTS;

  int _sec = 0;
  StreamSubscription _recorderSubscription;
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _recorder.openAudioSession(category: SessionCategory.record);
  }

  ///开始录制
  Future<void> _startRecord() async {
    try {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException("Microphone permission not granted");
      }
      Directory tempDir = await getTemporaryDirectory();
      path = '${tempDir.path}' +
          '/' +
          DateTime.now().millisecondsSinceEpoch.toString() +
          '.m4a';
      await _recorder.startRecorder(
          toFile: path, codec: _codec, audioSource: AudioSource.unprocessed);
      _isRecording = true;
      _recorderSubscription = _recorder.onProgress.listen((event) {
        if (event.decibels < 20) {
          if (overlayEntry != null) {
            overlayEntry.remove();
            overlayEntry = null;
            overlayEntry = showVoiceDialog(context);
          }
          if (mounted) setState(() {});
        } else if (event.decibels >= 20 && event.decibels < 40) {
          if (overlayEntry != null) {
            overlayEntry.remove();
            overlayEntry = null;
            overlayEntry = showVoiceDialog(context, index: 2);
          }
          if (mounted) setState(() {});
        } else if (event.decibels >= 40 && event.decibels < 60) {
          if (overlayEntry != null) {
            overlayEntry.remove();
            overlayEntry = null;
            overlayEntry = showVoiceDialog(context, index: 3);
          }
          if (mounted) setState(() {});
        } else if (event.decibels >= 60 && event.decibels < 80) {
          if (overlayEntry != null) {
            overlayEntry.remove();
            overlayEntry = null;
            overlayEntry = showVoiceDialog(context, index: 4);
          }
          if (mounted) setState(() {});
        } else if (event.decibels >= 80 && event.decibels < 100) {
          if (overlayEntry != null) {
            overlayEntry.remove();
            overlayEntry = null;
            overlayEntry = showVoiceDialog(context, index: 5);
          }
          if (mounted) setState(() {});
        } else if (event.decibels >= 100 && event.decibels < 120) {
          if (overlayEntry != null) {
            overlayEntry.remove();
            overlayEntry = null;
            overlayEntry = showVoiceDialog(context, index: 6);
          }
          if (mounted) setState(() {});
        } else {
          if (overlayEntry != null) {
            overlayEntry.remove();
            overlayEntry = null;
            overlayEntry = showVoiceDialog(context, index: 7);
          }
          if (mounted) setState(() {});
        }

        if (event != null && event.duration != null) {
          _sec = event.duration.inSeconds;
          if (_sec == 60) {
            _stop();
            if (mounted) {
              setState(() {
                _voiceTextShow = S.of(context).holdDownToSpeak;
                _voiceState = false;
              });
            }
            if (overlayEntry != null) {
              overlayEntry.remove();
              overlayEntry = null;
            }
          }
        }
      });
    } catch (e) {
      print('startRecorder error: $e');
      _stop();
      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }
    }
  }

  ///停止录制
  Future<void> _stop() async {
    try {
      await _recorder.stopRecorder();
      _isRecording = false;
      cancelRecorderSubscriptions();
    } catch (err) {
      print('停止录制 error: $err');
    }
  }

  void cancelRecorderSubscriptions() {
    if (_recorderSubscription != null) {
      _recorderSubscription.cancel();
      _recorderSubscription = null;
    }
  }

  showVoiceDialog(BuildContext context, {int index}) {
    OverlayEntry overlayEntry = new OverlayEntry(builder: (content) {
      return Material(
        type: MaterialType.transparency,
        child: _buildVoiceDialog(index: index),
      );
    });
    Overlay.of(context).insert(overlayEntry);

    return overlayEntry;
  }

  _buildVoiceDialog({int index}) {
    String icon;
    if (index == 2) {
      icon = 'assets/images/chat/voice_volume_2.webp';
    } else if (index == 3) {
      icon = 'assets/images/chat/voice_volume_3.webp';
    } else if (index == 4) {
      icon = 'assets/images/chat/voice_volume_4.webp';
    } else if (index == 5) {
      icon = 'assets/images/chat/voice_volume_5.webp';
    } else if (index == 6) {
      icon = 'assets/images/chat/voice_volume_6.webp';
    } else if (index == 7) {
      icon = 'assets/images/chat/voice_volume_7.webp';
    } else {
      icon = 'assets/images/chat/voice_volume_1.webp';
    }
    return Center(
      child: Opacity(
        opacity: 0.6,
        child: Container(
          width: 130,
          height: 130,
          margin: EdgeInsets.only(bottom: 75.0),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: 10.0,
                ),
                child: _isVoiceUp
                    ? ImageView(
                        img: 'assets/images/chat/ic_revoke.png',
                        width: 80.0,
                        height: 80.0,
                      )
                    : ImageView(img: icon, width: 80.0, height: 80.0),
              ),
              Container(
                color: _isVoiceUp ? Colors.red : Colors.transparent,
                padding: EdgeInsets.symmetric(
                  horizontal: 5.0,
                  vertical: 2.0,
                ),
                constraints: BoxConstraints(maxWidth: 120),
                child: Text(
                  _isVoiceUp
                      ? S.of(context).cancelSend
                      : S.of(context).fingerUp,
                  style: TextStyles.textF12T2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVoiceView(dy) {
    _startY = dy;
    if (mounted) {
      setState(() {
        _voiceTextShow = S.of(context).releaseSend;
        _voiceState = true;
        _isVoiceUp = false;
      });

      if (!_isRecording) {
        _startRecord();
      }

      if (overlayEntry == null) {
        overlayEntry = showVoiceDialog(context);
      }
    }
  }

  ///手指离开屏幕
  void _hideVoiceView() async {
    if (mounted) {
      setState(() {
        _voiceTextShow = S.of(context).holdDownToSpeak;
        _voiceState = false;
      });
    }

    _stop();

    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry = null;
    }
    if (!_isVoiceUp) {
      if (_sec > 1) {
        widget.call({'path': path, 'secoonds': _sec});
      } else {
        showToast(context, S.of(context).recordTimeShort, duration: 1);
      }
    }
  }

  ///滑动
  void _moveVoiceView(dy) {
    _offset = dy;
    _isVoiceUp = (_startY - _offset > 30);
    if (_isVoiceUp == true) {
      _voiceTextShow = S.of(context).releaseCancel;
      if (overlayEntry != null) {
        overlayEntry.remove();
        overlayEntry = null;
        overlayEntry = showVoiceDialog(context);
      }
    } else {
      _voiceTextShow = S.of(context).releaseSend;
      if (overlayEntry != null) {
        overlayEntry.remove();
        overlayEntry = null;
        overlayEntry = showVoiceDialog(context);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    cancelRecorderSubscriptions();
    releaseFlauto();
  }

  Future<void> releaseFlauto() async {
    try {
      await _recorder.closeAudioSession();
    } catch (e) {
      print('Released unsuccessful');
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 36.0,
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 6.0,
        ),
        decoration: BoxDecoration(
          color: _voiceState ? greyBCColor : AppColors.specialBgGray,
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(width: 0.3, color: greyB1Color),
        ),
        child: Text(
          _voiceTextShow == '' ? S.of(context).holdDownToSpeak : _voiceTextShow,
          style: _voiceState ? TextStyles.textF15T1 : TextStyles.textF15,
        ),
      ),
      onVerticalDragStart: (details) {
        _showVoiceView(details.globalPosition.dy);
      },
      onVerticalDragUpdate: (details) {
        _moveVoiceView(details.globalPosition.dy);
      },
      onVerticalDragEnd: (details) {
        _hideVoiceView();
      },
      onVerticalDragDown: (details) {
        _showVoiceView(details.globalPosition.dy);
      },
      onVerticalDragCancel: () {
        _hideVoiceView();
      },
    );
  }
}
