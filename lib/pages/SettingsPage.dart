import 'package:flutter/material.dart';
import 'package:flutter_osc/constants/Constants.dart';
import 'package:flutter_osc/events/LogoutEvent.dart';
import 'package:flutter_osc/pages/ChangeThemePage.dart';
import '../util/DataUtils.dart';

class SettingsPage extends StatelessWidget {
  static const String TAG_START = "startDivider";
  static const String TAG_END = "endDivider";
  static const String TAG_CENTER = "centerDivider";
  static const String TAG_BLANK = "blankDivider";

  static const double IMAGE_ICON_WIDTH = 30.0;
  static const double ARROW_ICON_WIDTH = 16.0;

  final titleTextStyle = TextStyle(fontSize: 16.0);
  final rightArrowIcon = Image.asset(
    'images/ic_arrow_right.png',
    width: ARROW_ICON_WIDTH,
    height: ARROW_ICON_WIDTH,
  );

  final List listData = [];

  SettingsPage() {
    listData.add(TAG_BLANK);
    listData.add(TAG_START);
    listData.add(ListItem(title: '切换主题', icon: 'images/ic_discover_nearby.png'));
    listData.add(TAG_CENTER);
    listData.add(ListItem(title: '退出登录', icon: 'images/ic_discover_nearby.png'));
    listData.add(TAG_END);
  }

  Widget getIconImage(path) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
      child: Image.asset(path,
          width: IMAGE_ICON_WIDTH, height: IMAGE_ICON_WIDTH),
    );
  }

  _renderRow(BuildContext ctx, int i) {
    var item = listData[i];
    if (item is String) {
      Widget w;
      switch (item) {
        case TAG_START:
        case TAG_END:
          w = Divider(
            height: 1.0,
          );
          break;
        case TAG_CENTER:
          w = Padding(
            padding: const EdgeInsets.fromLTRB(50.0, 0.0, 0.0, 0.0),
            child: Divider(
              height: 1.0,
            ),
          );
          break;
        case TAG_BLANK:
          w = Container(
            height: 20.0,
          );
          break;
        default:
          w = Divider(
            height: 1.0,
          );
      }
      return w;
    } else if (item is ListItem) {
      var listItemContent = Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
        child: Row(
          children: <Widget>[
            getIconImage(item.icon),
            Expanded(
                child: Text(
              item.title,
              style: titleTextStyle,
            )),
            rightArrowIcon
          ],
        ),
      );
      return InkWell(
        onTap: () {
          String title = item.title;
          if (title == '退出登录') {
            DataUtils.clearLoginInfo().then((arg) {
              Navigator.of(ctx).pop();
              Constants.eventBus.fire(LogoutEvent());
              print("event fired!");
            });
          } else if (title == '切换主题') {
            Navigator.push(ctx, MaterialPageRoute(builder: (ctx) {
              return ChangeThemePage();
            }));
          }
        },
        child: listItemContent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设置", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemBuilder: (ctx, i) => _renderRow(ctx, i),
        itemCount: listData.length,
      ),
    );
  }
}

class ListItem {
  String icon;
  String title;
  ListItem({this.icon, this.title});
}
