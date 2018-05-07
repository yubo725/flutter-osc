
import 'package:flutter/material.dart';
import '../pages/AboutPage.dart';
import '../pages/BlackHousePage.dart';
import '../pages/PublishTweetPage.dart';
import '../pages/SettingsPage.dart';

class MyDrawer extends StatelessWidget {

  static const double IMAGE_ICON_WIDTH = 30.0;
  static const double ARROW_ICON_WIDTH = 16.0;
  var rightArrowIcon = new Image.asset('images/ic_arrow_right.png', width: ARROW_ICON_WIDTH, height: ARROW_ICON_WIDTH,);
  List menuTitles = ['发布动弹', '动弹小黑屋', '关于', '设置'];
  List menuIcons = ['./images/leftmenu/ic_fabu.png', './images/leftmenu/ic_xiaoheiwu.png', './images/leftmenu/ic_about.png', './images/leftmenu/ic_settings.png'];
  TextStyle menuStyle = new TextStyle(
    fontSize: 15.0,
  );

  @override
  Widget build(BuildContext context) {
    return new ConstrainedBox(
      constraints: const BoxConstraints.expand(width: 304.0),
      child: new Material(
        elevation: 16.0,
        child: new Container(
          decoration: new BoxDecoration(
            color: const Color(0xFFFFFFFF),
          ),
          child: new ListView.builder(
            itemCount: menuTitles.length * 2 + 1,
            itemBuilder: renderRow,
          ),
        ),
      ),
    );
  }

  Widget getIconImage(path) {
    return new Padding(
      padding: const EdgeInsets.fromLTRB(2.0, 0.0, 6.0, 0.0),
      child: new Image.asset(path, width: 28.0, height: 28.0),
    );
  }

  Widget renderRow(BuildContext context, int index) {
    if (index == 0) {
      // render cover image
      var img = new Image.asset('./images/cover_img.jpg', width: 304.0, height: 304.0,);
      return new Container(
        width: 304.0,
        height: 304.0,
        margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
        child: img,
      );
    }
    index -= 1;
    if (index.isOdd) {
      return new Divider();
    }
    index = index ~/2;

    var listItemContent =  new Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
      child: new Row(
        children: <Widget>[
          getIconImage(menuIcons[index]),
          new Expanded(
              child: new Text(menuTitles[index], style: menuStyle,)
          ),
          rightArrowIcon
        ],
      ),
    );

    return new InkWell(
      child: listItemContent,
      onTap: () {
        switch (index) {
          case 0:
            // 发布动弹
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (ctx) {
                  return new PublishTweetPage();
                }
            ));
            break;
          case 1:
            // 小黑屋
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (ctx) {
                  return new BlackHousePage();
                }
            ));
            break;
          case 2:
            // 关于
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (ctx) {
                  return new AboutPage();
                }
            ));
            break;
          case 3:
            // 设置
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (ctx) {
                  return new SettingsPage();
                }
            ));
            break;
        }
      },
    );
  }
}