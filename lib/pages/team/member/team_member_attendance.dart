// import 'package:cobiz_client/tools/cobiz.dart';
// import 'package:cobiz_client/ui/view/list_row_view.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class AttendancePage extends StatefulWidget {
//   AttendancePage({Key key}) : super(key: key);

//   @override
//   _AttendancePageState createState() => _AttendancePageState();
// }

// class _AttendancePageState extends State<AttendancePage> {
//   List panelList = [
//     {'isOpen': false, 'title': '平均工时'},
//     {'isOpen': false, 'title': '出勤天数'},
//     {'isOpen': false, 'title': '出勤班次'},
//     {'isOpen': false, 'title': '休息天数'},
//     {'isOpen': false, 'title': '迟到'},
//     {'isOpen': false, 'title': '早退'},
//     {'isOpen': false, 'title': '缺卡'},
//     {'isOpen': false, 'title': '矿工'},
//     {'isOpen': false, 'title': '外勤'},
//     {'isOpen': false, 'title': '加班'},
//   ];

//   _body(BuildContext context) {
//     return Expanded(
//         child: SingleChildScrollView(
//             physics: BouncingScrollPhysics(),
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 15, vertical: 1),
//               child: Column(children: [
//                 ExpansionPanelList(
//                     expandedHeaderPadding: EdgeInsets.zero,
//                     expansionCallback: (panelIndex, isExpanded) {
//                       setState(() {
//                         panelList[panelIndex]['isOpen'] =
//                             !panelList[panelIndex]['isOpen'];
//                       });
//                     },
//                     animationDuration: kThemeAnimationDuration,
//                     children: List.generate(panelList.length, (index) {
//                       return ExpansionPanel(
//                           isExpanded: panelList[index]['isOpen'],
//                           headerBuilder: (context, isExpanded) {
//                             return ListTile(
//                               title: Text(
//                                 panelList[index]['title'],
//                                 style: TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                               trailing: Text('2'),
//                             );
//                           },
//                           body: Padding(
//                             padding: EdgeInsets.fromLTRB(16, 0, 16, 15),
//                             child: ListBody(
//                               children: [
//                                 Text('2019-07-14 星期三'),
//                                 Text('2019-07-14 星期三'),
//                                 Text('2019-07-14 星期三')
//                               ],
//                             ),
//                           ));
//                     }))
//               ]),
//             )));
//   }

//   Widget _header(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//           color: AppColors.mainColor,
//           borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(15),
//               bottomRight: Radius.circular(15))),
//       padding: EdgeInsets.only(bottom: 10.0),
//       child: ListRowView(
//         color: AppColors.mainColor,
//         haveBorder: false,
//         paddingRight: 15.0,
//         paddingLeft: 15.0,
//         // paddingBottom: 10,
//         iconRt: 15.0,
//         iconWidget: InkWell(
//           child: Container(
//             decoration: ShapeDecoration(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadiusDirectional.circular(40.0),
//                 side: BorderSide(color: Colors.grey, width: 0.3),
//               ),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(40.0),
//               child: ImageView(
//                 // img: cuttingAvatar(
//                 //     widget.teamMemberWithUser?.userProfileImage ?? ''),
//                 img: 'https://avatar.csdnimg.cn/2/9/2/3_jking54.jpg',
//                 needLoad: true,
//                 width: 65,
//                 height: 65,
//               ),
//             ),
//           ),
//           // onTap: () => onProfileImageClick(model),
//         ),
//         titleWidget: Text(
//           'name',
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           style: TextStyles.myStyle,
//         ),
//         labelWidget: Container(
//           padding: EdgeInsets.only(
//             top: 5.0,
//           ),
//           child: Text(
//             '考勤组: 深圳市腾讯计算机系统有限公司',
//             style: TextStyles.textF14T2,
//           ),
//         ),
//         onPressed: () async {},
//       ),
//     );
//   }

//   Widget _rWidget = FlatButton(
//     onPressed: () {},
//     child: Row(
//       children: [
//         Text('打卡日历  ', style: TextStyle(color: Colors.white)),
//         ImageView(img: 'assets/images/team/calendar_white.png')
//       ],
//     ),
//   );
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: AppColors.white,
//       appBar: ComMomBar(
//         mainColor: AppColors.white,
//         backgroundColor: AppColors.mainColor,
//         rightDMActions: [_rWidget],
//       ),
//       body: Column(
//         children: [
//           _header(context),
//           SizedBox(
//             height: 15,
//           ),
//           _body(context),
//           SizedBox(
//             height: 20,
//           )
//         ],
//       ),
//     );
//   }
// }
