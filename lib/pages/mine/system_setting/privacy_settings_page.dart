import 'package:cobiz_client/pages/mine/ui/titled_box.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/switch_line_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'active_session_page.dart';
import 'two_step_verification_page.dart';

class PrivacySettingsPage extends StatefulWidget {
  PrivacySettingsPage();

  @override
  _PrivacySettingsPageState createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool syncContacts = false;
  bool pushFrequentContacts = false;
  bool linkPreview = false;

  // 隐私
  List<Widget> buidPrivacyItems(GlobalModel model, Map privacyValueNames) {
    List<Widget> list = [];
    List data = [
      {
        "title": S.of(context).userBlocked,
        "rightTxt": S.of(context).none,
      },
      {
        "title": S.of(context).phoneNumber,
        "rightTxt": privacyValueNames["contact"]
      },
      {
        "title": S.of(context).onlineStatus,
        "rightTxt": privacyValueNames["contact"]
      },
      {"title": S.of(context).avatar, "rightTxt": privacyValueNames["contact"]},
      {
        "title": S.of(context).citationForwardingSource,
        "rightTxt": privacyValueNames["contact"]
      },
      {"title": S.of(context).call, "rightTxt": privacyValueNames["contact"]},
      {"title": S.of(context).invite, "rightTxt": privacyValueNames["contact"]},
    ];

    data.forEach((element) {
      list.add(OperateLineView(
        title: element["title"],
        rightWidget: new Text(
          element["rightTxt"],
          style: TextStyle(
              fontSize: 14,
              color: model.currentTheme.primaryTheme.primaryColor),
        ),
        onPressed: () {},
      ));
    });

    return list;
  }

  // 安全
  List<Widget> buidSecureItems(GlobalModel model, Map privacyValueNames) {
    List<Widget> list = [];
    List data = [
      {
        "title": S.of(context).twoStepVerification,
        "onPressed": () {
          routePush(TwoStepVerificationPage());
        }
      },
      {
        "title": S.of(context).activeSession,
        "onPressed": () {
          routePush(ActiveSessionPage());
        }
      },
    ];

    data.forEach((element) {
      list.add(OperateLineView(
        title: element["title"],
        onPressed: element["onPressed"],
      ));
    });

    return list;
  }

  // 联系人
  List<Widget> buidContactsItems(GlobalModel model, Map privacyValueNames) {
    List<Widget> list = [
      OperateLineView(
        title: S.of(context).emptyCloudContacts,
        onPressed: () {},
      )
    ];
    List data = [
      {
        "title": S.of(context).syncContacts,
        "value": syncContacts,
        "onChanged": (value) {
          if (mounted) {
            setState(() {
              syncContacts = value;
            });
          }
        }
      },
      {
        "title": S.of(context).pushFrequentContacts,
        "value": pushFrequentContacts,
        "onChanged": (value) {
          if (mounted) {
            setState(() {
              pushFrequentContacts = value;
            });
          }
        }
      },
    ];

    data.forEach((element) {
      list.add(
        SwitchLineView(
          title: S.of(context).syncContacts,
          value: element["value"],
          onChanged: element["onChanged"],
        ),
      );
    });

    return list;
  }

  // 加密
  List<Widget> buidAdvancedItems(GlobalModel model, Map privacyValueNames) {
    List<Widget> list = [
      OperateLineView(
        title: S.of(context).deleteAllFavorites,
        onPressed: () {},
      ),
      OperateLineView(
        title: S.of(context).deleteMyAccountIfAwayFor,
        rightWidget: new Text(
          privacyValueNames["contact"],
          style: TextStyle(
              fontSize: 14,
              color: model.currentTheme.primaryTheme.primaryColor),
        ),
        onPressed: () {},
      ),
      SwitchLineView(
        title: S.of(context).linkPreview,
        value: linkPreview,
        onChanged: (value) {
          if (mounted) {
            setState(() {
              linkPreview = value;
            });
          }
        },
      ),
    ];

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<GlobalModel>(context, listen: false);
    Map<String, String> privacyValueNames = {
      "none": S.of(context).none,
      "contact": S.of(context).contacts,
      "all": S.of(context).everyone,
    };
    return Scaffold(
      appBar: new ComMomBar(
        title: S.of(context).privacySecurity,
        elevation: 0.5,
      ),
      body: Container(
        color: model.currentTheme.primaryTheme.scaffoldBackgroundColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TitledBox(
                title: S.of(context).privacy,
                children: buidPrivacyItems(model, privacyValueNames),
              ),
              TitledBox(
                title: S.of(context).secureChat,
                margin: EdgeInsets.only(top: 10),
                children: buidSecureItems(model, privacyValueNames),
              ),
              TitledBox(
                title: S.of(context).contacts,
                margin: EdgeInsets.only(top: 10),
                children: buidContactsItems(model, privacyValueNames),
              ),
              TitledBox(
                title: S.of(context).advanced,
                margin: EdgeInsets.only(top: 10, bottom: 40),
                children: buidAdvancedItems(model, privacyValueNames),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
