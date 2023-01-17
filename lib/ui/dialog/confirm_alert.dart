import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showConfirm(BuildContext context,
    {bool barrierDismissible = false, // 是否允许点击遮罩层关闭提示框
    bool canPop = true, //是否可以物理返回
    // delete/delete_forever, access_time/schedule, save, error_outline, contact_phone, supervisor_account
    Widget iconWidget, // 标题的图标(优先)
    IconData iconData, // 标题的图标
    String title, // 提示的标题
    String content, // 提示的文本内容
    Widget contentWidget, //优先
    String sureBtn, // 确认按钮文本(默认: 是)
    String cancelBtn, // 取消按钮文本(默认: 否)
    VoidCallback sureCallBack, // 确认按钮的点击回调函数
    VoidCallback cancelCallBack, // 取消按钮的点击回调函数
    TextAlign textAlign}) {
  showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return WillPopScope(
          child: SimpleDialog(
            contentPadding: EdgeInsets.fromLTRB(0, 12, 0, 0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: (iconWidget != null || iconData != null)
                ? Row(children: <Widget>[
                    iconWidget ?? Icon(iconData),
                    SizedBox(width: 5.0),
                    Expanded(
                      child: Text(title ?? S.of(context).confirmTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16.0)),
                    ),
                  ])
                : Text(title ?? S.of(context).confirmTitle,
                    textAlign: textAlign, style: TextStyle(fontSize: 16.0)),
            children: <Widget>[
              Container(
                constraints: BoxConstraints(maxHeight: winHeight(context) / 2),
                child: Row(
                  children: <Widget>[
                    contentWidget != null
                        ? Expanded(
                            child: SingleChildScrollView(
                                child: contentWidget,
                                physics: BouncingScrollPhysics()))
                        : Expanded(
                            child: content != null
                                ? SingleChildScrollView(
                                    physics: BouncingScrollPhysics(),
                                    padding: EdgeInsets.only(
                                        left: 20.0, right: 20.0, bottom: 20.0),
                                    child: ListBody(
                                      children: <Widget>[
                                        Text(content ?? '',
                                            style: TextStyle(
                                                fontSize: 13.0,
                                                color: Colors.grey))
                                      ],
                                    ),
                                  )
                                : Container(height: 30.0),
                          )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  // SizedBox(width: 20.0),
                  Expanded(
                    child: CupertinoButton(
                      child: Text(cancelBtn ?? S.of(context).no,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal)),
                      color: Color(0xFFECECEC),
                      padding: EdgeInsets.all(0),
                      pressedOpacity: 0.8,
                      borderRadius:
                          BorderRadius.only(bottomLeft: Radius.circular(10)),
                      onPressed: () {
                        Navigator.pop(context);
                        if (cancelCallBack != null) cancelCallBack();
                      },
                    ),
                  ),
                  // SizedBox(width: 10),
                  Expanded(
                    child: CupertinoButton(
                      child: Text(sureBtn ?? S.of(context).yes,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal)),
                      color: AppColors.mainColor,
                      padding: EdgeInsets.all(0),
                      pressedOpacity: 0.8,
                      borderRadius:
                          BorderRadius.only(bottomRight: Radius.circular(10)),
                      onPressed: () {
                        Navigator.pop(context);
                        if (sureCallBack != null) sureCallBack();
                      },
                    ),
                  ),
                  // SizedBox(width: 20.0)
                ],
              )
            ],
          ),
          onWillPop: () async => canPop);
    },
  );
}

void showAlert(
  BuildContext context, {
  bool barrierDismissible = false, // 是否允许点击遮罩层关闭提示框
  bool canPop = true, //是否可以物理返回
  // delete/delete_forever, access_time/schedule, save, error_outline, contact_phone, supervisor_account
  Widget iconWidget, // 标题的图标(优先)
  IconData iconData, // 标题的图标
  String title, // 提示的标题
  String content, // 提示的文本内容
  Widget contentWidget, //优先
  String sureBtn, // 确认按钮文本(默认: 确定)
  VoidCallback sureCallBack, // 确认按钮的点击回调函数
}) {
  showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return WillPopScope(
          child: SimpleDialog(
            contentPadding: EdgeInsets.fromLTRB(0, 12, 0, 0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: (iconWidget != null || iconData != null)
                ? Row(children: <Widget>[
                    iconWidget ?? Icon(iconData),
                    SizedBox(width: 5.0),
                    Text(title ?? S.of(context).confirmTitle,
                        style: TextStyle(fontSize: 16.0))
                  ])
                : Text(title ?? S.of(context).confirmTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.0)),
            children: <Widget>[
              Container(
                constraints: BoxConstraints(maxHeight: winHeight(context) / 2),
                child: Row(
                  children: <Widget>[
                    contentWidget != null
                        ? Expanded(
                            child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: contentWidget,
                          ))
                        : Expanded(
                            child: content != null
                                ? SingleChildScrollView(
                                    physics: BouncingScrollPhysics(),
                                    padding: EdgeInsets.only(
                                        left: 20.0, right: 20.0, bottom: 20.0),
                                    child: ListBody(
                                      children: <Widget>[
                                        Text(content ?? '',
                                            style: TextStyle(
                                                fontSize: 13.0,
                                                color: Colors.grey))
                                      ],
                                    ),
                                  )
                                : Container(height: 30.0),
                          )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              // Row(
              //   children: <Widget>[
              //     Expanded(
              //       child: content != null
              //           ? SingleChildScrollView(
              //               padding: EdgeInsets.only(
              //                   left: 20.0, right: 20.0, bottom: 30.0),
              //               child: ListBody(
              //                 children: <Widget>[
              //                   Text(content ?? '',
              //                       style: TextStyle(
              //                           fontSize: 13.0, color: Colors.grey))
              //                 ],
              //               ),
              //             )
              //           : Container(height: 30.0),
              //     )
              //   ],
              // ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: CupertinoButton(
                      child: Text(sureBtn ?? S.of(context).ok,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal)),
                      color: themeColor,
                      padding: EdgeInsets.all(0),
                      pressedOpacity: 0.8,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10)),
                      onPressed: () {
                        Navigator.pop(context);
                        if (sureCallBack != null) sureCallBack();
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
          onWillPop: () async => canPop);
    },
  );
}
