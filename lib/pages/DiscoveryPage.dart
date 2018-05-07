import 'package:flutter/material.dart';

class DiscoveryPage extends StatelessWidget {

  static const String TAG_START = "startDivider";
  static const String TAG_END = "endDivider";
  static const String TAG_CENTER = "centerDivider";
  static const String TAG_BLANK = "blankDivider";

  static const double IMAGE_ICON_WIDTH = 30.0;
  static const double ARROW_ICON_WIDTH = 16.0;

  var imagePaths = [
    "images/ic_discover_softwares.png",
    "images/ic_discover_git.png",
    "images/ic_discover_gist.png",
    "images/ic_discover_scan.png",
    "images/ic_discover_shake.png",
    "images/ic_discover_nearby.png",
    "images/ic_discover_pos.png",
  ];
  var titles = [
    "开源软件", "码云推荐", "代码片段", "扫一扫", "摇一摇", "附近的程序员", "线下活动"
  ];
  var rightArrowIcon = new Image.asset('images/ic_arrow_right.png', width: ARROW_ICON_WIDTH, height: ARROW_ICON_WIDTH,);
  var titleTextStyle = new TextStyle(fontSize: 16.0);
  List listData = [];

  DiscoveryPage() {
    initData();
  }

  initData() {
    listData.add(TAG_START);
    for (int i = 0; i < 3; i++) {
      listData.add(new ListItem(title: titles[i], icon: imagePaths[i]));
      if (i == 2) {
        listData.add(TAG_END);
      } else {
        listData.add(TAG_CENTER);
      }
    }
    listData.add(TAG_BLANK);
    listData.add(TAG_START);
    for (int i = 3; i < 5; i++) {
      listData.add(new ListItem(title: titles[i], icon: imagePaths[i]));
      if (i == 4) {
        listData.add(TAG_END);
      } else {
        listData.add(TAG_CENTER);
      }
    }
    listData.add(TAG_BLANK);
    listData.add(TAG_START);
    for (int i = 5; i < 7; i++) {
      listData.add(new ListItem(title: titles[i], icon: imagePaths[i]));
      if (i == 6) {
        listData.add(TAG_END);
      } else {
        listData.add(TAG_CENTER);
      }
    }
  }

  Widget getIconImage(path) {
    return new Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
      child: new Image.asset(path, width: IMAGE_ICON_WIDTH, height: IMAGE_ICON_WIDTH),
    );
  }

  renderRow(i) {
    var item = listData[i];
    if (item is String) {
      switch (item) {
        case TAG_START:
          return new Divider(height: 1.0,);
          break;
        case TAG_END:
          return new Divider(height: 1.0,);
          break;
        case TAG_CENTER:
          return new Padding(
            padding: const EdgeInsets.fromLTRB(50.0, 0.0, 0.0, 0.0),
            child: new Divider(height: 1.0,),
          );
          break;
        case TAG_BLANK:
          return new Container(
            height: 20.0,
          );
          break;
      }
    } else if (item is ListItem) {
      var listItemContent =  new Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
        child: new Row(
          children: <Widget>[
            getIconImage(item.icon),
            new Expanded(
                child: new Text(item.title, style: titleTextStyle,)
            ),
            rightArrowIcon
          ],
        ),
      );
      return new GestureDetector(
        child: new InkWell(
          onTap: () {},
          child: listItemContent,
        ),
        onTap: () {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
      child: new ListView.builder(
        itemCount: listData.length,
        itemBuilder: (context, i) => renderRow(i),
      ),
    );
  }

}

class ListItem {
  String icon;
  String title;
  ListItem({this.icon, this.title});
}