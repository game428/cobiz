import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/special_text/emoji_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef void OnEmojiSelected(String emoji);

class ChannelEmoji extends StatefulWidget {
  final bool isInited;
  final bool isEmoji;
  final double keyboardHeight;
  final bool isChanged;
  final FocusNode textFocus;
  final TextEditingController textController;
  final OnEmojiSelected onEmojiSelected;
  final VoidCallback onTapSend;

  const ChannelEmoji(
      {Key key,
      this.isInited,
      this.isEmoji,
      this.keyboardHeight,
      this.isChanged,
      this.textFocus,
      this.textController,
      this.onEmojiSelected,
      this.onTapSend})
      : super(key: key);

  @override
  _ChannelEmojiState createState() => _ChannelEmojiState();
}

class _ChannelEmojiState extends State<ChannelEmoji> {
  @override
  void initState() {
    super.initState();
  }

  void _deleteEmoji() {
    if (widget.textController.text.length > 0) {
      int lastIndex = widget.textController.text.lastIndexOf('[');
      if (widget.textController.text
                  .substring(widget.textController.text.length - 1) ==
              ']' &&
          lastIndex >= 0) {
        String str = widget.textController.text.substring(lastIndex);
        if (EmojiUitl.instance.isEmoji(str) && mounted) {
          setState(() {
            widget.textController.text =
                widget.textController.text.substring(0, lastIndex);
          });
          return;
        }
      }
      if (mounted) {
        setState(() {
          widget.textController.text = widget.textController.text
              .substring(0, widget.textController.text.length - 1);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = (ScreenData.width - 30) / 7 - 0.5;
    return GestureDetector(
      child: Container(
        height: widget.isEmoji ? widget.keyboardHeight : 0.0,
        width: ScreenData.width,
        padding: EdgeInsets.only(
            left: 15, right: 15, bottom: ScreenData.bottomSafeHeight),
        color: Colors.white,
        child: widget.isInited
            ? Stack(
                children: <Widget>[
                  ListView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      top: 15.0,
                      bottom: 60.0,
                    ),
                    children: <Widget>[
                      Wrap(
                        runSpacing: 15.0,
                        spacing: 0.0,
                        children: List.generate(
                            EmojiUitl.instance.emojis.length, (index) {
                          Emoji emoji =
                              EmojiUitl.instance.emojis['e${index + 1}'];
                          return emoji != null
                              ? InkWell(
                                  child: Container(
                                    width: width,
                                    child: Column(
                                      children: <Widget>[
                                        ImageView(
                                          img: emoji.path,
                                          width: 30.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    if (widget.onEmojiSelected != null &&
                                        widget.textController.text.length <
                                            inputWordNum) {
                                      widget.onEmojiSelected(emoji.text ?? '');
                                    }
                                  },
                                )
                              : Container();
                        }),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: Colors.white,
                      width: width * 3,
                      padding: EdgeInsets.only(
                        top: 10.0,
                        bottom: 15.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          CupertinoButton(
                            child: ImageView(
                              img: 'assets/images/ic_delete.webp',
                            ),
                            color: greyECColor,
                            pressedOpacity: 0.8,
                            minSize: 36.0,
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                            onPressed: _deleteEmoji,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          CupertinoButton(
                            child: Text(
                              S.of(context).send,
                              style: widget.isChanged
                                  ? TextStyles.textF14T2
                                  : TextStyles.textF14T1,
                            ),
                            color: widget.isChanged
                                ? AppColors.mainColor
                                : greyECColor,
                            pressedOpacity: 0.8,
                            minSize: 36.0,
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                            onPressed: widget.onTapSend ?? () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(
                height: 0.0,
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
