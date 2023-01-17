import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cobiz_client/pages/common/web_view.dart';
import 'package:cobiz_client/provider/global_model.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/http/common.dart' as commonApi;

class UserAgreement extends StatefulWidget {
  @override
  _UserAgreementState createState() => _UserAgreementState();
}

class _UserAgreementState extends State<UserAgreement> {
  GlobalModel _model;
  String _url;

  @override
  void initState() {
    super.initState();
    _model = Provider.of<GlobalModel>(context, listen: false);
    _getData(_model.currentLocale.languageCode +
        '_' +
        _model.currentLocale.countryCode);
  }

  _getData(String language) async {
    _url = await commonApi.getAgreementUrl(1, language);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
        title: S.of(context).userAgreement,
        elevation: 0.5,
      ),
      body: _url != null
          ? WebViewPage(_url)
          : Center(
              child: CupertinoActivityIndicator(),
            ),
    );
  }
}
