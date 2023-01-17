import 'package:cobiz_client/config/app_styles.dart';
import 'package:flutter/material.dart';

class CustomThemeData {
  final ThemeData primaryTheme; //主题
  final Color textColor; //默认文字颜色
  final Color textColorLight; //默认文字颜色，亮色
  final Color textColorDark; //默认文字颜色，亮色
  final Color chatBackgroundColor; //聊天背景色
  final Color lineColor; //分隔线颜色
  final Color tipColor; //普通提示文本颜色
  final Color errorTipColor; //错误提示文本颜色

  final double defaultSpace; //默认间距
  final double defaultLineWidth; //默认线宽
  final double errorTipFontSize; //错误提示字体大小
  final double fontSizeMiddle; //中号字体

  CustomThemeData(
    this.primaryTheme, {
    this.textColor,
    this.textColorLight,
    this.textColorDark,
    this.chatBackgroundColor,
    this.lineColor,
    this.tipColor,
    this.errorTipColor,
    this.defaultSpace = ThemeModel.defaultSpace,
    this.defaultLineWidth = ThemeModel.defaultLineWidth,
    this.errorTipFontSize = ThemeModel.defaultErrorTipFontSize,
    this.fontSizeMiddle = ThemeModel.defaultFontSizeMiddle,
  });
}

mixin ThemeModel {
  static const double defaultSpace = 10;
  static const double defaultLineWidth = 0.3;
  static const Color defaultLineColor = Colors.grey;
  static const Color defaultTextColor = Colors.grey;
  static const Color defaultTextColorLight = Colors.white;
  static const Color defaultTextColorDark = Colors.black;
  static const double defaultErrorTipFontSize = 13;
  static const double defaultFontSizeMiddle = 12;
  static const Color defaultErrorTipFontColor = Color(0xFFFF0000);
  static const Color defaultTipColor = Color(0xFF596073);
  static const Color defaultItemBgColor = Color(0xFF00EDED);

  CustomThemeData currentTheme = lightTheme;

  static final CustomThemeData lightTheme = new CustomThemeData(
    new ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.mainColor, foregroundColor: Colors.black),
      accentColor: Colors.blueAccent[100],
      primaryColor: Color(0xFF09C497),
      primaryColorLight: Color(0xFF23c399),
      primaryColorDark: Color(0xFF09C030),
      textSelectionHandleColor: Colors.blue[700],
      dividerColor: Colors.grey[200],
      bottomAppBarColor: Colors.grey[700],
      buttonColor: Colors.blue[700],
      iconTheme: new IconThemeData(color: Colors.blueGrey),
      primaryIconTheme: new IconThemeData(color: Colors.black),
      accentIconTheme: new IconThemeData(color: Colors.blue[700]),
      disabledColor: Colors.grey[500],
      scaffoldBackgroundColor: Color(0xFFFFFFFF),
      hintColor: Colors.grey.withOpacity(0.3),
      splashColor: Colors.transparent,
      canvasColor: Colors.transparent,
      backgroundColor: Colors.white,
      appBarTheme: AppBarTheme(color: AppColors.mainColor),
    ),
    textColor: defaultTextColor,
    textColorLight: defaultTextColorLight,
    textColorDark: defaultTextColorDark,
    chatBackgroundColor: Color(0xffefefef),
    lineColor: defaultLineColor,
    tipColor: defaultTipColor,
    errorTipColor: defaultErrorTipFontColor,
  );
}
