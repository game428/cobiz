import 'package:flutter/material.dart';
import 'package:cobiz_client/domain/menu_domain.dart';
import 'package:cobiz_client/ui/view/image_view.dart';

typedef PopupSelectedCallback = void Function(PMenuItem item);

class PopupMenu extends StatelessWidget {
  final List<PMenuItem> list;
  final Widget icon;
  final PopupSelectedCallback onSelected;

  const PopupMenu({Key key, @required this.list, this.icon, this.onSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PMenuItem>(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        onSelected: onSelected ?? () {},
        offset: Offset(0, 40),
        icon: icon ?? Icon(Icons.add, color: Colors.black),
        itemBuilder: (BuildContext context) {
          List<PopupMenuEntry<PMenuItem>> items =
              List<PopupMenuEntry<PMenuItem>>();
          for (PMenuItem item in list) {
            items.add(PopupMenuItem(
              value: item,
              child: Row(
                children: <Widget>[
                  item.icon.isNotEmpty
                      ? ImageView(
                          img: item.icon,
                          width: 25.0,
                        )
                      : Container(),
                  item.icon.isNotEmpty
                      ? SizedBox(
                          width: 15.0,
                        )
                      : Container(),
                  Expanded(
                    child: Text(
                      item.title,
                      style: item.titleStyle,
                      textAlign: item.icon.isNotEmpty ? null : TextAlign.center,
                    ),
                  )
                ],
              ),
            ));
          }
          return items;
        });
  }
}
