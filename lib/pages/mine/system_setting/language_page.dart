import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguagePage extends StatefulWidget {
  LanguagePage({Key key}) : super(key: key);

  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  LanguageData _languageData;
  final List<LanguageData> languageDatas = [
    LanguageData("中文", "zh", "CN", "Cobiz-flutter"),
    LanguageData("English", "en", "US", "Cobiz-flutter"),
    LanguageData("中文繁體", "zh", "TW", "Cobiz-flutter"),
  ];
  String _lang;
  GlobalModel model;
  bool isChangeLang = false;

  @override
  void initState() {
    super.initState();
    model = Provider.of<GlobalModel>(context, listen: false);
    if (mounted) {
      setState(() {
        _lang = model.currentLanguageCode[1];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var body = List.generate(languageDatas.length, (index) {
      return RadioListTile(
        title: Text(languageDatas[index].language),
        value: languageDatas[index].countryCode,
        activeColor: AppColors.mainColor,
        groupValue: _lang,
        onChanged: (v) {
          String language = model.currentLanguageCode[1];
          isChangeLang = language != v;
          if (mounted) {
            setState(() {
              _lang = v;
              _languageData = languageDatas[index];
            });
          }
        },
      );
    }).toList();
    return new Scaffold(
      appBar: new ComMomBar(
        title: S.of(context).multiLanguage,
        elevation: 0.5,
        rightDMActions: <Widget>[
          buildSureBtn(
            text: S.of(context).confirmTitle,
            textStyle:
                isChangeLang ? TextStyles.textF14T2 : TextStyles.textF14T1,
            color: isChangeLang ? AppColors.mainColor : greyECColor,
            onPressed: () {
              if (isChangeLang) {
                SharedUtil.instance.saveStringList(Keys.currentLanguageCode,
                    [_languageData.languageCode, _languageData.countryCode]);
                model.changeLanguage(Locale(
                    _languageData.languageCode, _languageData.countryCode));
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: body,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class LanguageData {
  String language;
  String languageCode;
  String countryCode;
  String appName;

  LanguageData(
      this.language, this.languageCode, this.countryCode, this.appName);
}
