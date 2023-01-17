import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class FontSizePage extends StatefulWidget {
  FontSizePage({Key key}) : super(key: key);

  @override
  _FontSizePageState createState() => _FontSizePageState();
}

class _FontSizePageState extends State<FontSizePage> {
  int _fz = 1;
  bool _isLoadingOk = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    double _tScale = await SharedUtil.instance.getDouble(Keys.fontSize) ?? 1.0;
    _fz = _textScaleDoubleToInt(_tScale);
    _isLoadingOk = true;

    if (mounted) {
      setState(() {});
    }
  }

  _onDone() async {
    if (_textScaleIntToDouble() !=
        (await SharedUtil.instance.getDouble(Keys.fontSize) ?? 1.0)) {
      await SharedUtil.instance
          .saveDouble(Keys.fontSize, _textScaleIntToDouble());
      eventBus.emit(EVENT_FONT_SIZE, _textScaleIntToDouble());
    }
    Navigator.pop(context);
  }

  int _textScaleDoubleToInt(double textScale) {
    if (textScale == 0.8) {
      return 0;
    } else if (textScale == 1.0) {
      return 1;
    } else if (textScale == 1.1) {
      return 2;
    } else if (textScale == 1.2) {
      return 3;
    } else if (textScale == 1.3) {
      return 4;
    } else {
      return 1;
    }
  }

  double _textScaleIntToDouble() {
    switch (_fz) {
      case 0:
        return 0.8;
      case 1:
        return 1.0;
      case 2:
        return 1.1;
      case 3:
        return 1.2;
      case 4:
        return 1.3;
      default:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ComMomBar(
          title: S.of(context).fontSize,
          elevation: 0.5,
          rightDMActions: [
            _isLoadingOk
                ? buildSureBtn(
                    text: S.of(context).confirmTitle,
                    textStyle: TextStyles.textF14T2,
                    color: AppColors.mainColor,
                    onPressed: _onDone,
                  )
                : Container(),
          ],
        ),
        body: Container(
          color: AppColors.specialBgGray,
          padding:
              EdgeInsets.fromLTRB(0, 30, 0, 30 + ScreenData.bottomSafeHeight),
          child: Column(
            children: [
              Expanded(
                  child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Text(S.of(context).fontSizeH1,
                          textScaleFactor: _textScaleIntToDouble(),
                          style: TextStyle(fontSize: 14)),
                      SizedBox(height: 10),
                      Text(S.of(context).fontSizeH2,
                          textScaleFactor: _textScaleIntToDouble(),
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Text(S.of(context).fontSizeH3,
                          textScaleFactor: _textScaleIntToDouble(),
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )),
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 15),
                alignment: Alignment.center,
                width: winWidth(context),
                child: Row(
                  children: [
                    Text('A', textScaleFactor: 0.8),
                    Expanded(
                        child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              thumbColor: AppColors.mainColor,
                              activeTrackColor:
                                  AppColors.mainColor.withOpacity(0.5),
                              inactiveTrackColor: greyB1Color,
                              activeTickMarkColor: Colors.black,
                              disabledActiveTickMarkColor: Colors.black,
                              inactiveTickMarkColor: Colors.black,
                              tickMarkShape:
                                  RoundSliderTickMarkShape(tickMarkRadius: 3.0),
                            ),
                            child: Slider(
                                value: _fz.toDouble(),
                                divisions: 4,
                                min: 0.0,
                                max: 4.0,
                                onChanged: (v) {
                                  if (mounted) {
                                    setState(() {
                                      _fz = v.round();
                                    });
                                  }
                                }))),
                    Text('A', textScaleFactor: 1.3),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
