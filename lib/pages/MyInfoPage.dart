import 'package:flutter/material.dart';
import 'package:flutter_osc/constants/Constants.dart';
import 'package:flutter_osc/events/ChangeThemeEvent.dart';
import 'package:flutter_osc/events/LoginEvent.dart';
import 'package:flutter_osc/events/LogoutEvent.dart';
import 'package:flutter_osc/util/ThemeUtils.dart';
import '../pages/CommonWebPage.dart';
import '../pages/LoginPage.dart';
import '../pages/NewLoginPage.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/Api.dart';
import '../util/NetUtils.dart';
import '../util/DataUtils.dart';
import '../model/UserInfo.dart';

class MyInfoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyInfoPageState();
  }
}

class MyInfoPageState extends State<MyInfoPage> {
  Color themeColor = ThemeUtils.currentColorTheme;

  static const double IMAGE_ICON_WIDTH = 30.0;
  static const double ARROW_ICON_WIDTH = 16.0;

  var titles = ["我的消息", "阅读记录", "我的博客", "我的问答", "我的活动", "我的团队", "邀请好友"];
  var imagePaths = [
    "images/ic_my_message.png",
    "images/ic_my_blog.png",
    "images/ic_my_blog.png",
    "images/ic_my_question.png",
    "images/ic_discover_pos.png",
    "images/ic_my_team.png",
    "images/ic_my_recommend.png"
  ];
  var icons = [];
  var userAvatar;
  var userName;
  var titleTextStyle = TextStyle(fontSize: 16.0);
  var rightArrowIcon = Image.asset(
    'images/ic_arrow_right.png',
    width: ARROW_ICON_WIDTH,
    height: ARROW_ICON_WIDTH,
  );

  MyInfoPageState() {
    for (int i = 0; i < imagePaths.length; i++) {
      icons.add(getIconImage(imagePaths[i]));
    }
  }

  @override
  void initState() {
    super.initState();
    _showUserInfo();
    Constants.eventBus.on<LogoutEvent>().listen((event) {
      // 收到退出登录的消息，刷新个人信息显示
      _showUserInfo();
    });
    Constants.eventBus.on<LoginEvent>().listen((event) {
      // 收到登录的消息，重新获取个人信息
      getUserInfo();
    });
    Constants.eventBus.on<ChangeThemeEvent>().listen((event) {
      setState(() {
        themeColor = event.color;
      });
    });
  }

  _showUserInfo() {
    DataUtils.getUserInfo().then((UserInfo userInfo) {
      if (userInfo != null) {
        print(userInfo.name);
        print(userInfo.avatar);
        setState(() {
          userAvatar = userInfo.avatar;
          userName = userInfo.name;
        });
      } else {
        setState(() {
          userAvatar = null;
          userName = null;
        });
      }
    });
  }

  Widget getIconImage(path) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
      child: Image.asset(path,
          width: IMAGE_ICON_WIDTH, height: IMAGE_ICON_WIDTH),
    );
  }

  @override
  Widget build(BuildContext context) {
    var listView = ListView.builder(
      itemCount: titles.length * 2,
      itemBuilder: (context, i) => renderRow(i),
    );
    return listView;
  }

  // 获取用户信息
  getUserInfo() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String accessToken = sp.get(DataUtils.SP_AC_TOKEN);
      Map<String, String> params = Map();
      params['access_token'] = accessToken;
      NetUtils.get(Api.userInfo, params: params).then((data) {
        if (data != null) {
          var map = json.decode(data);
          setState(() {
            userAvatar = map['avatar'];
            userName = map['name'];
          });
          DataUtils.saveUserInfo(map);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  _login() async {
    // 打开登录页并处理登录成功的回调
    final result = await Navigator
        .of(context)
        .push(MaterialPageRoute(builder: (context) {
      return NewLoginPage();
    }));
    // result为"refresh"代表登录成功
    if (result != null && result == "refresh") {
      // 刷新用户信息
      getUserInfo();
      // 通知动弹页面刷新
      Constants.eventBus.fire(LoginEvent());
    }
  }

  _showUserInfoDetail() {}

  renderRow(i) {
    if (i == 0) {
      var avatarContainer = Container(
        color: themeColor,
        height: 200.0,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              userAvatar == null
                  ? Image.asset(
                      "images/ic_avatar_default.png",
                      width: 60.0,
                    )
                  : Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        image: DecorationImage(
                            image: NetworkImage(userAvatar),
                            fit: BoxFit.cover),
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                    ),
              Text(
                userName == null ? "点击头像登录" : userName,
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ],
          ),
        ),
      );
      return GestureDetector(
        onTap: () {
          DataUtils.isLogin().then((isLogin) {
            if (isLogin) {
              // 已登录，显示用户详细信息
              _showUserInfoDetail();
            } else {
              // 未登录，跳转到登录页面
              _login();
            }
          });
        },
        child: avatarContainer,
      );
    }
    --i;
    if (i.isOdd) {
      return Divider(
        height: 1.0,
      );
    }
    i = i ~/ 2;
    String title = titles[i];
    var listItemContent = Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
      child: Row(
        children: <Widget>[
          icons[i],
          Expanded(
              child: Text(
            title,
            style: titleTextStyle,
          )),
          rightArrowIcon
        ],
      ),
    );
    return InkWell(
      child: listItemContent,
      onTap: () {
        _handleListItemClick(title);
//        Navigator
//            .of(context)
//            .push(MaterialPageRoute(builder: (context) => CommonWebPage(title: "Test", url: "https://my.oschina.net/u/815261/blog")));
      },
    );
  }

  _showLoginDialog() {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('提示'),
            content: Text('没有登录，现在去登录吗？'),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  '取消',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(
                  '确定',
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _login();
                },
              )
            ],
          );
        });
  }

  _handleListItemClick(String title) {
    DataUtils.isLogin().then((isLogin) {
      if (!isLogin) {
        // 未登录
        _showLoginDialog();
      } else {
        DataUtils.getUserInfo().then((info) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CommonWebPage(
                title: "我的博客",
                url: "https://my.oschina.net/u/${info.id}/blog"
              )
            ));
        });
      }
    });
  }
}
