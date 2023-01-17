import 'dart:convert';
import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/http/res/team_model/search_team_info.dart';
import 'package:cobiz_client/pages/team/team_page/apply_join.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/search_navbar_view.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/team.dart' as teamApi;

class SearchTeamPage extends StatefulWidget {
  @override
  _SearchTeamPageState createState() => _SearchTeamPageState();
}

class _SearchTeamPageState extends State<SearchTeamPage> {
  final TextEditingController _queryTextController = TextEditingController();
  bool _isLoading = false;

  List<String> _historyKeys = [];
  List<SearchTeamInfo> _teamItems = [];
  Widget _body = Container();
  List teamTypeJson = List();

  @override
  void initState() {
    super.initState();
    _queryTextController.addListener(_getSearchData);
    _getHistoryKeys();
    _getTypeData();
  }

  _getTypeData() async {
    GlobalModel model = Provider.of<GlobalModel>(context, listen: false);
    List<String> codes = model.currentLanguageCode;
    teamTypeJson = json.decode(await rootBundle
        .loadString('assets/data/team_types_${codes[0]}_${codes[1]}.json'));
  }

  void _getHistoryKeys() async {
    final List<String> keys = await SharedUtil.instance
        .getStringList('${Keys.teamSearchHistoryKeys}${API.userInfo.id}');
    if (keys != null && (keys?.length ?? 0) > 0 && mounted) {
      setState(() {
        _historyKeys.addAll(keys);
      });
    }
  }

  void _updateHistoryKeys() async {
    final String text = _queryTextController.text;
    if (text.length < 1 || _historyKeys.contains(text)) return;

    if (mounted) {
      setState(() {
        _historyKeys.insert(0, text);
        if (_historyKeys.length > 8) _historyKeys.removeLast();
        SharedUtil.instance.saveStringList(
            '${Keys.teamSearchHistoryKeys}${API.userInfo.id}', _historyKeys);
      });
    }
  }

  _onSub(String text) async {
    _teamItems = await teamApi.searchTeam(text);
    if (_teamItems.isEmpty) {
      _body = Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.only(top: 50, left: 50, right: 50),
        child: Text(
          S.of(context).searchNothing(text),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _getSearchData() async {
    if (_queryTextController.text.isEmpty) {
      if (mounted) {
        setState(() {
          _body = _buildSearchDefault();
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _body = ListItemView(
            onPressed: () {
              _onSub(_queryTextController.text);
            },
            titleWidget: Row(
              children: <Widget>[
                Text('${S.of(context).search}：',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    )),
                Expanded(
                    child: Text('${_queryTextController.text}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                        )))
              ],
            ),
            iconWidget: ClipOval(
              child: ImageView(
                img: searchImage,
                width: 35.0,
                height: 35.0,
                fit: BoxFit.cover,
              ),
            ),
          );
        });
      }
    }
  }

  Widget _buildKeyword(String name) {
    return Container(
      child: InkWell(
        child: Chip(
          label: Text(
            name,
            style: TextStyles.textF14C1,
          ),
          backgroundColor: greyF6Color,
        ),
        onTap: () {
          _queryTextController.text = name;
          final int length = name.length;
          _queryTextController.selection = TextSelection(
            baseOffset: length - 1,
            extentOffset: length,
          );
        },
      ),
    );
  }

  Widget _buildSearchDefault() {
    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              left: 15.0,
              right: 15.0,
              bottom: 15.0,
              top: 5.0,
            ),
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    S.of(context).historyKeyWord,
                    style: TextStyles.textF16,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 10.0,
                    children: _historyKeys.map((text) {
                      return _buildKeyword(text);
                    }).toList(),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchResult() {
    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: ListView.builder(
        itemCount: _teamItems.length,
        itemBuilder: (context, index) {
          String _type = S.of(context).other;
          for (var i = 0; i < teamTypeJson.length; i++) {
            if (teamTypeJson[i]['value'] == _teamItems[index].type) {
              _type = teamTypeJson[i]['text'];
              break;
            }
          }
          String logo = logoImageG;
          if (strNoEmpty(_teamItems[index].icon)) {
            logo = _teamItems[index].icon;
          }
          return ListItemView(
            title: '${_teamItems[index].name}',
            label: _type,
            iconWidget: ImageView(
              img: cuttingAvatar(logo),
              width: 42.0,
              height: 42.0,
              needLoad: true,
              isRadius: 21.0,
              fit: BoxFit.cover,
            ),
            onPressed: () {
              _updateHistoryKeys();
              routePush(ApplyJoinTeamPage(
                type: 1,
                team: _teamItems[index],
              ));
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      explicitChildNodes: true,
      scopesRoute: true,
      namesRoute: true,
      child: Scaffold(
        appBar: SearchNavbarView(
          textController: _queryTextController,
          hintText: S.of(context).teamSearchHintText,
          onChanged: (v) {
            if (_teamItems.isNotEmpty) {
              _teamItems.clear();
            }
          },
        ),
        body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isLoading
                ? (_teamItems.isEmpty ? _body : _buildSearchResult())
                : _buildSearchDefault()),
        backgroundColor: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    _queryTextController.dispose();
    super.dispose();
  }
}
