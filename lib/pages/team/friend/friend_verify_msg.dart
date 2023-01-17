import 'package:cobiz_client/domain/azlistview_domain.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/http/contact.dart';
import 'package:cobiz_client/http/res/user.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/list_item_view.dart';
import 'package:cobiz_client/ui/view/shadow_card_view.dart';

class FriendVerifyMsg extends StatefulWidget {
  final UserInfo userInfo; //从用户信息进来
  final MyContact myContact; //手机号才传
  FriendVerifyMsg({Key key, this.myContact, this.userInfo})
      : assert(userInfo != null || myContact != null),
        super(key: key);

  @override
  _FriendVerifyMsgState createState() => _FriendVerifyMsgState();
}

class _FriendVerifyMsgState extends State<FriendVerifyMsg> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Widget _fiter() {
    if (widget.myContact != null) {
      return ListItemView(
        iconWidget: ClipOval(
          child: Container(
            color: AppColors.mainColor,
            width: 42.0,
            height: 42.0,
            alignment: Alignment.center,
            child: Text(
                widget.myContact.fullName.length > 2
                    ? widget.myContact.fullName.substring(
                        widget.myContact.fullName.length - 2,
                        widget.myContact.fullName.length)
                    : widget.myContact.fullName,
                style: TextStyle(
                  color: Colors.white,
                )),
          ),
        ),
        title: widget.myContact.fullName,
        label: widget.myContact.phoneNumber,
        dense: true,
        haveBorder: false,
        paddingRight: 20.0,
      );
    } else if (widget.userInfo != null) {
      return ListItemView(
        title: widget.userInfo.nickname,
        haveBorder: false,
        vertical: 10,
        iconWidget: ImageView(
          img: cuttingAvatar(widget.userInfo.avatar),
          width: 42.0,
          height: 42.0,
          needLoad: true,
          isRadius: 21.0,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Text('error');
    }
  }

  Future _onSub() async {
    Loading.before(context: context);
    var res;
    if (widget.userInfo != null) {
      res = await addContact(1,
          userId: widget.userInfo.id,
          msg: _controller.text.isEmpty
              ? S.of(context).iAmWho(API.userInfo.nickname)
              : _controller.text);
    } else if (widget.myContact != null) {
      res = await addContact(2,
          phone: widget.myContact.phoneNumber,
          msg: _controller.text.isEmpty
              ? S.of(context).iAmWho(API.userInfo.nickname)
              : _controller.text);
    }
    Loading.complete();
    // if (res == 1 || res == 5) return showToast(context, '申请失败');
    if (res == 3) return showToast(context, S.of(context).alreadyFriends);
    // if (res == 4) return showToast(context, '指定添加的账号异常');
    showToast(context, S.of(context).applicationSentOk);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (mounted)
      setState(() {
        _controller.text = S.of(context).iAmWho(API.userInfo.nickname);
      });
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: ComMomBar(
          title: S.of(context).friendRequests,
          elevation: 0.5,
          rightDMActions: <Widget>[
            buildSureBtn(
              text: S.of(context).send,
              textStyle: TextStyles.textF14T2,
              color: AppColors.mainColor,
              onPressed: _onSub,
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            _fiter(),
            ShadowCardView(
              radius: 5.0,
              blurRadius: 2.0,
              margin:
                  EdgeInsets.only(top: 25.0, bottom: 10.0, left: 15, right: 15),
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  buildTextTitle(
                    S.of(context).verifyMessage,
                    left: 15.0,
                    top: 0.0,
                  ),
                  EditLineView(
                    minHeight: 40.0,
                    top: 10.0,
                    textAlign: TextAlign.left,
                    textController: _controller,
                    hintText: '',
                    maxLen: 50,
                    textFieldLines: 3,
                    showMaxLen: true,
                    haveBorder: false,
                  )
                ],
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
