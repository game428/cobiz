import 'package:cobiz_client/pages/dialogue/channel/channel_ui/channel_recording.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';

class ChannelInputBar extends StatefulWidget {
  final bool isVoice;
  final bool isEmoji;
  final bool isMore;
  final FocusNode textFocus;
  final TextEditingController textController;
  final GestureTapCallback voiceTap;
  final VoidCallback emojiTap;
  final GestureTapCallback moreTap;
  final VoidCallback onTapSend;
  final Function(String) onChanged;
  final Function(Map) sendVoice;

  const ChannelInputBar(
      {Key key,
      this.isVoice,
      this.isEmoji,
      this.isMore,
      this.textFocus,
      this.textController,
      this.voiceTap,
      this.emojiTap,
      this.moreTap,
      this.onTapSend,
      this.onChanged,
      this.sendVoice})
      : super(key: key);

  @override
  _ChannelInputBarState createState() => _ChannelInputBarState();
}

class _ChannelInputBarState extends State<ChannelInputBar> {
  bool isAndroid = false;

  @override
  void initState() {
    super.initState();
    widget.textController.addListener(() {
      var text = widget.textController.text;
      if (Platform.isAndroid && mounted) {
        setState(() {
          isAndroid = text.length > 0;
        });
      }
    });
  }

  Widget _buildTextFiled() {
    return Container(
      constraints: BoxConstraints(maxHeight: 120.0),
      margin: EdgeInsets.only(
        left: 10.0,
        right: 10.0,
        bottom: 7.5,
        top: 6.0,
      ),
      decoration: BoxDecoration(
        color: AppColors.specialBgGray,
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(width: 0.3, color: greyB1Color),
      ),
      child: TextField(
        scrollPhysics: BouncingScrollPhysics(),
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.send,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontSize: 15.0),
          hintText: S.of(context).enterTheMessageContent,
          isDense: true,
          contentPadding: EdgeInsets.only(
            top: 8.5,
            bottom: 5.0,
            left: 5.0,
            right: 5.0,
          ),
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
        controller: widget.textController,
        focusNode: widget.textFocus,
        style: TextStyles.textF15,
        onChanged: widget.onChanged,
        inputFormatters: <TextInputFormatter>[
          LengthLimitingTextInputFormatter(inputWordNum)
        ],
        onSubmitted: (data) {
          FocusScope.of(context).requestFocus(widget.textFocus);
          if (widget.onTapSend != null) widget.onTapSend();
        },
      ),
    );
  }

  Widget _buildVoice() {
    return ChatRecordingVoice((path) {
      if (widget.sendVoice != null) {
        widget.sendVoice(path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        constraints: BoxConstraints(minHeight: 50.0, maxHeight: 120.0),
        padding: EdgeInsets.only(
            left: 8,
            right: 8,
            bottom: !widget.isEmoji && !widget.isMore
                ? ScreenData.bottomSafeHeight
                : 0.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: Colors.grey, width: 0.3),
            bottom: BorderSide(color: Colors.grey, width: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            InkWell(
              child: Container(
                child: ImageView(
                  img:
                      'assets/images/chat/${widget.isVoice ? 'keyboard' : 'voice'}.png',
                  width: 25.0,
                  fit: BoxFit.cover,
                ),
              ),
              onTap: () {
                if (widget.voiceTap != null) {
                  widget.voiceTap();
                }
              },
            ),
            Expanded(
              child: widget.isVoice ? _buildVoice() : _buildTextFiled(),
            ),
            InkWell(
              child: Container(
                child: ImageView(
                  img: 'assets/images/chat/emoji.png',
                  width: 25.0,
                  fit: BoxFit.cover,
                ),
              ),
              onTap: () {
                if (widget.emojiTap != null) {
                  widget.emojiTap();
                }
              },
            ),
            SizedBox(
              width: 10.0,
            ),
            (isAndroid && !widget.isEmoji)
                ? InkWell(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                      decoration: BoxDecoration(
                        color: AppColors.mainColor,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Text(
                        S.of(context).send,
                        style: TextStyles.textF14T2,
                      ),
                    ),
                    onTap: () {
                      FocusScope.of(context).requestFocus(widget.textFocus);
                      if (widget.onTapSend != null) {
                        widget.onTapSend();
                        if (mounted) {
                          setState(() {
                            isAndroid = false;
                          });
                        }
                      }
                    },
                  )
                : InkWell(
                    child: Container(
                      child: ImageView(
                        img: 'assets/images/chat/more.png',
                        width: 25.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    onTap: () {
                      if (widget.moreTap != null) {
                        widget.moreTap();
                      }
                    },
                  ),
          ],
        ),
      ),
      onTap: () {},
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
