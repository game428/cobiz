import 'package:cobiz_client/config/location.dart';
import 'package:cobiz_client/pages/start_page.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CobizApp extends StatefulWidget {
  CobizApp({Key key}) : super(key: key);

  @override
  _CobizAppState createState() => _CobizAppState();
}

class _CobizAppState extends State<CobizApp> {
  double _textScaleFactor = 1.0;

  @override
  void initState() {
    super.initState();
    eventBus.on(EVENT_FONT_SIZE, (arg) {
      if (arg != null) {
        if (mounted) {
          setState(() {
            _textScaleFactor = arg;
          });
        }
      }
    });
    _init();
  }

  _init() async {
    _textScaleFactor =
        await SharedUtil.instance.getDouble(Keys.fontSize) ?? 1.0;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<GlobalModel>(context)..setContext(context);
    Location.loadArea().then((v) {
      if (v.code == '') {
        Location.setCurrentArea(Location.currentArea());
      }
    });

    return MaterialApp(
      navigatorKey: navGK,
      title: model.appName,
      theme: model.currentTheme.primaryTheme,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      locale: model.currentLocale,
      home: StartPage(),
      builder: (context, widget) {
        return MediaQuery(
          ///设置文字大小不随系统设置改变
          data: MediaQuery.of(context)
              .copyWith(textScaleFactor: _textScaleFactor),
          child: widget,
        );
      },
    );
  }

  @override
  void dispose() {
    eventBus.off(EVENT_FONT_SIZE);
    super.dispose();
  }
}
