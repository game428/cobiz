import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';

String searchImage = 'assets/images/search.png';
String settingImage = 'assets/images/team/setting.png';
String arrowRtImage = 'assets/images/ic_arrow_right.png';
String arrowDnImage = 'assets/images/ic_arrow_down.png';
String importantImage = 'assets/images/ic_important.png';
String chatImage = 'assets/images/ic_chat.png';
String deleteImage = 'assets/images/ic_delete.png';
String roundCloseImage = 'assets/images/ic_round_close.png';
String plusImage = 'assets/images/work/plus.png';
String noMsg = 'assets/images/no_msg.png';
String noContent = 'assets/images/no_content.png';

String logoImage = 'assets/images/cobiz.png';
String logoImageG = 'assets/images/cobiz_g.png';

int inputWordNum = 300; //输入框长度

///app颜色
class AppColors {
  static const Color mainColor = Color(0xFF09C497); //主色
  static const Color secondaryColor = Color(0xFF9de8d5); //辅色
  static const Color warnRed = Color(0xFFd74e68); //提醒红色
  static const Color specialGray = Color(0xFFdedede); //特殊灰色
  static const Color specialBgGray = Color(0xFFf6f6f6); //特殊背景灰色
  static const Color font_c1 = Color(0xFF202025); //特殊大标题字体颜色
  static const Color font_c2 = Color(0xFF818181); //大字号字体颜色
  static const Color font_c3 = Color(0xFF202025); //大字号2字体颜色
  static const Color font_c4 = Color(0xFFbcbcbc); //中字号字体颜色
  static const Color font_c5 = Color(0xFFa3a3a3); //灰色小子号字体颜色
  static const Color red = Colors.red; //红
  static const Color black = Colors.black; //黑
  static const Color white = Colors.white; //白
}

///app字体大小
class FontSizes {
  static const double font_s10 = 10.0;
  static const double font_s11 = 11.0;
  static const double font_s12 = 12.0;
  static const double font_s13 = 13.0;
  static const double font_s14 = 14.0;
  static const double font_s15 = 15.0;
  static const double font_s16 = 16.0;
  static const double font_s17 = 17.0;
  static const double font_s18 = 18.0;
  static const double font_s19 = 19.0;
  static const double font_s20 = 20.0;
  static const double font_s21 = 21.0;
  static const double font_s22 = 22.0;
  static const double font_s23 = 23.0;
  static const double font_s24 = 24.0;
  static const double font_s25 = 25.0;
  static const double font_s26 = 26.0;
  static const double font_s27 = 27.0;
  static const double font_s28 = 28.0;
  static const double font_s29 = 29.0;
  static const double font_s30 = 30.0;
}

const Color themeColor = const Color(0xFF09C497);
const Color radiusBgColor = const Color(0xFFD4FDF3);
const Color grey28Color = const Color(0xFF282828);
const Color grey81Color = const Color(0xFF818181);
const Color greyA0Color = const Color(0xFFA0A0A0);
const Color greyA3Color = const Color(0xFFA3A3A3);
const Color greyAAColor = const Color(0xFFAAAAAA);
const Color greyB1Color = const Color(0xFFB1B1B1);
const Color greyBCColor = const Color(0xFFBCBCBC);
const Color greyC1Color = const Color(0xFFC1C1C1);
const Color greyC6Color = const Color(0xFFC6C6C6);
const Color greyCAColor = const Color(0xFFCACACA);
const Color greyDFColor = const Color(0xFFDFDFDF);
const Color greyE5Color = const Color(0xFFE5EAF5);
const Color greyE6Color = const Color(0xFFE6EBEC);
const Color greyEAColor = const Color(0xFFEAEAEA);
const Color greyECColor = const Color(0xFFECECEC);
const Color greyEFColor = const Color(0xFFEFEFEF);
const Color greyF6Color = const Color(0xFFF6F6F6);
const Color greyF7Color = const Color(0xFFF7F7F7);
const Color greyF9Color = const Color(0xFFF9F9F9);
const Color red68Color = const Color(0xFFD74E68);
const Color blueDEColor = const Color(0xFF6E96DE);
const Color black18Color = const Color(0xFF181818);

class TextStyles {
  static TextStyle textStyle(
      {double fontSize: FontSizes.font_s14,
      FontWeight fontWeight,
      Color color,
      double height}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      decoration: TextDecoration.none,
      height: height,
    );
  }

  static TextStyle textDefault = textStyle();
  static TextStyle textNoneLabel = textStyle(
    fontSize: FontSizes.font_s14,
    color: greyA0Color,
  );
  static TextStyle textF12 = textStyle(
    fontSize: FontSizes.font_s12,
  );
  static TextStyle textF12T1 = textStyle(
    fontSize: FontSizes.font_s12,
    color: grey81Color,
  );
  static TextStyle textRedF12T1 = textStyle(
    fontSize: FontSizes.font_s12,
    color: AppColors.red,
  );
  static TextStyle textF12T2 = textStyle(
    fontSize: FontSizes.font_s12,
    color: Colors.white,
  );
  static TextStyle textF12T3 = textStyle(
    fontSize: FontSizes.font_s12,
    color: greyE5Color,
  );
  static TextStyle textF12T4 = textStyle(
    fontSize: FontSizes.font_s12,
    color: grey28Color,
  );
  static TextStyle textF12T5 = textStyle(
    fontSize: FontSizes.font_s12,
    color: greyBCColor,
  );
  static TextStyle textF13 = textStyle(
    fontSize: FontSizes.font_s13,
  );
  static TextStyle textF13T1 = textStyle(
    fontSize: FontSizes.font_s13,
    color: grey81Color,
  );
  static TextStyle textF14 = textStyle(
    fontSize: FontSizes.font_s14,
  );
  static TextStyle textF14T1 = textStyle(
    fontSize: FontSizes.font_s14,
    color: grey81Color,
  );
  static TextStyle textF14T2 = textStyle(
    fontSize: FontSizes.font_s14,
    color: Colors.white,
  );
  static TextStyle textF14T3 = textStyle(
    fontSize: FontSizes.font_s14,
    color: grey28Color,
  );
  static TextStyle textF14T4 = textStyle(
    fontSize: FontSizes.font_s14,
    color: greyA3Color,
  );
  static TextStyle textF14T5 = textStyle(
    fontSize: FontSizes.font_s14,
    color: AppColors.mainColor,
  );
  static TextStyle textF15 = textStyle(
    fontSize: FontSizes.font_s15,
  );
  static TextStyle textF15T1 = textStyle(
    fontSize: FontSizes.font_s15,
    color: Colors.white,
  );
  static TextStyle textF16 = textStyle(
    fontSize: FontSizes.font_s16,
  );
  static TextStyle textF16Bold = textStyle(
    fontSize: FontSizes.font_s16,
    fontWeight: FontWeight.bold,
  );
  static TextStyle textF16T1 = textStyle(
    fontSize: FontSizes.font_s16,
    color: Colors.white,
  );
  static TextStyle textF16T2 = textStyle(
    fontSize: FontSizes.font_s16,
    color: greyB1Color,
  );
  static TextStyle textF16T3 = textStyle(
    fontSize: FontSizes.font_s16,
    color: blueDEColor,
  );
  static TextStyle textF16T4 = textStyle(
    fontSize: FontSizes.font_s16,
    color: grey81Color,
  );
  static TextStyle textF16T5 = textStyle(
    fontSize: FontSizes.font_s16,
    color: Colors.red,
  );
  static TextStyle textF16T6 = textStyle(
    fontSize: FontSizes.font_s16,
    fontWeight: FontWeight.bold,
    color: grey28Color,
  );
  static TextStyle textF16T7 = textStyle(
    fontSize: FontSizes.font_s16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static TextStyle textF16T8 = textStyle(
    fontSize: FontSizes.font_s16,
    color: Color(0xFFff8c8c),
  );
  static TextStyle textF16T9 = textStyle(
    fontSize: FontSizes.font_s16,
    color: grey28Color,
  );
  static TextStyle textF17T1 = textStyle(
    fontSize: FontSizes.font_s17,
    color: Colors.white,
  );
  static TextStyle textF17T2 = textStyle(
    fontSize: FontSizes.font_s17,
    color: themeColor,
  );
  static TextStyle textF17T3 = textStyle(
    fontSize: FontSizes.font_s17,
    color: grey28Color,
  );
  static TextStyle textF18 = textStyle(
    fontSize: FontSizes.font_s18,
  );
  static TextStyle textF18T1 = textStyle(
    fontSize: FontSizes.font_s18,
    color: Colors.white,
  );
  static TextStyle textF18T2 = textStyle(
    fontSize: FontSizes.font_s18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static TextStyle textF20T1 = textStyle(
    fontSize: FontSizes.font_s20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static TextStyle textF20T2 = textStyle(
    fontSize: FontSizes.font_s20,
    fontWeight: FontWeight.bold,
    color: grey28Color,
  );
  static TextStyle textF22T1 = textStyle(
    fontSize: FontSizes.font_s22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static TextStyle chatBoxStyle = TextStyle(
      textBaseline: TextBaseline.alphabetic,
      fontSize: FontSizes.font_s20,
      color: black18Color);
  static TextStyle sendGoldStyle = TextStyle(
    fontSize: FontSizes.font_s30,
    color: grey28Color,
  );
  static TextStyle myStyle = TextStyle(
    fontSize: FontSizes.font_s20,
    color: Colors.white,
  );
  static TextStyle textCreate = textStyle(
    fontSize: FontSizes.font_s18,
    fontWeight: FontWeight.normal,
    color: themeColor,
  );
  static TextStyle textContactTitle = textStyle(
    fontSize: FontSizes.font_s18,
    fontWeight: FontWeight.bold,
  );
  static TextStyle textF10C1 = textStyle(
    fontSize: FontSizes.font_s10,
    color: Colors.white,
  );
  static TextStyle textF10C2 = textStyle(
    fontSize: FontSizes.font_s10,
    color: greyA0Color,
  );
  static TextStyle textNum = textStyle(
    fontSize: FontSizes.font_s12,
    color: greyBCColor,
  );
  static TextStyle textTeamAddMark = textStyle(
    fontSize: FontSizes.font_s12,
    height: 2.0,
  );
  static TextStyle textF12C1 = textStyle(
    fontSize: FontSizes.font_s12,
    color: greyC6Color,
  );
  static TextStyle textF12C2 = textStyle(
    fontSize: FontSizes.font_s12,
    color: Colors.white,
  );
  static TextStyle textF12C3 = textStyle(
    fontSize: FontSizes.font_s12,
    color: themeColor,
  );
  static TextStyle textF12C4 = textStyle(
    fontSize: FontSizes.font_s12,
    color: greyA0Color,
  );
  static TextStyle textF12C5 = textStyle(
    fontSize: FontSizes.font_s12,
    color: Colors.black,
  );
  static TextStyle textF12C6 = textStyle(
    fontSize: FontSizes.font_s12,
    color: red68Color,
  );
  static TextStyle textF14C1 = textStyle(
    fontSize: FontSizes.font_s14,
    color: greyA3Color,
  );
  static TextStyle textF14C2 = textStyle(
    fontSize: FontSizes.font_s14,
    color: Colors.black,
  );
  static TextStyle textF14C3 = textStyle(
    fontSize: FontSizes.font_s14,
    color: Colors.white,
  );
  static TextStyle textF14C4 = textStyle(
    fontSize: FontSizes.font_s14,
    color: red68Color,
  );
  static TextStyle textF14C5 = textStyle(
    fontSize: FontSizes.font_s14,
    color: greyAAColor,
  );
  static TextStyle textF14C6 = textStyle(
    fontSize: FontSizes.font_s14,
    color: themeColor,
  );
  static TextStyle textF14Tl = textStyle(
    fontSize: FontSizes.font_s14,
    fontWeight: FontWeight.w500,
  );
  static TextStyle textF15C1 = textStyle(
    fontSize: FontSizes.font_s15,
    color: greyB1Color,
  );
  static TextStyle textF16C1 = textStyle(
    fontSize: FontSizes.font_s16,
    color: themeColor,
  );
  static TextStyle textF16C2 = textStyle(
    fontSize: FontSizes.font_s16,
    color: Colors.white,
  );
  static TextStyle textF16C3 = textStyle(
    fontSize: FontSizes.font_s16,
    color: Colors.black,
  );
  static TextStyle textF16C4 = textStyle(
    fontSize: FontSizes.font_s16,
    color: greyB1Color,
  );
  static TextStyle textTabSel = textStyle(
    fontSize: FontSizes.font_s20,
    fontWeight: FontWeight.bold,
    height: 1.4,
  );
  static TextStyle textTabUnSel = textStyle(
    fontSize: FontSizes.font_s16,
    height: 2.0,
  );
  static TextStyle textNavTitle = textStyle(
    fontSize: FontSizes.font_s20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
}
