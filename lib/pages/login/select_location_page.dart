import 'package:cobiz_client/config/location.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';

class SelectLocationPage extends StatefulWidget {
  @override
  _SelectLocationPageState createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  List<Area> state;

  Widget buildState(context, index) {
    var item = state[index];

    var content = new Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      padding: EdgeInsets.symmetric(vertical: 20.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.2),
        ),
      ),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Text(
            '${item.name}',
            style: TextStyle(fontSize: 15.0),
          ),
          new Text(
            '${item.code}',
            style: TextStyle(fontSize: 15.0, color: Colors.green),
          ),
        ],
      ),
    );

    return new InkWell(
      child: content,
      onTap: () => Navigator.pop(context, item),
    );
  }

  @override
  Widget build(BuildContext context) {
    state = Location.areaList(context);

    return new Scaffold(
      appBar: new ComMomBar(
        title: S.of(context).selectCountry,
        elevation: 0.5,
      ),
      body: new ListView.builder(
          itemBuilder: buildState, itemCount: state.length),
    );
  }
}
