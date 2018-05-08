import 'package:flutter/material.dart';
import 'package:flutter_osc/constants/Constants.dart';
import 'package:flutter_osc/events/LoginEvent.dart';
import 'package:flutter_osc/util/BlackListUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/NetUtils.dart';
import '../api/Api.dart';
import 'dart:convert';
import '../pages/LoginPage.dart';
import '../util/DataUtils.dart';
import '../util/Utf8Utils.dart';

class BlackHousePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new BlackHousePageState();
  }
}

class BlackHousePageState extends State<BlackHousePage> {
  bool isLogin = true;
  List blackDataList;
  TextStyle btnStyle = new TextStyle(color: Colors.white, fontSize: 12.0);

  BlackHousePageState() {
    queryBlackList();
  }

  queryBlackList() {
    DataUtils.getUserInfo().then((userInfo) {
      if (userInfo != null) {
        String url = Api.QUERY_BLACK;
        url += "/${userInfo.id}";
        NetUtils.get(url, (data) {
          if (data != null) {
            var obj = json.decode(data);
            if (obj['code'] == 0) {
              setState(() {
                blackDataList = obj['msg'];
              });
            }
          }
        }, errorCallback: (e) {
          print("network error: $e");
        });
      } else {
        setState(() {
          isLogin = false;
        });
      }
    });
  }

  // 获取用户信息
  getUserInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String accessToken = sp.get(DataUtils.SP_AC_TOKEN);
    Map<String, String> params = new Map();
    params['access_token'] = accessToken;
    NetUtils.get(Api.USER_INFO, (data) {
      if (data != null) {
        var map = json.decode(data);
        DataUtils.saveUserInfo(map).then((userInfo) {
          queryBlackList();
        });
      }
    }, params: params);
  }

  // 从黑名单中删除
  deleteFromBlack(authorId) {
    DataUtils.getUserInfo().then((userInfo) {
      if (userInfo != null) {
        String userId = "${userInfo.id}";
        Map<String, String> params = new Map();
        params['userid'] = userId;
        params['authorid'] = "$authorId";
        NetUtils.get(
          Api.DELETE_BLACK,
          (data) {
            Navigator.of(context).pop();
            if (data != null) {
              var obj = json.decode(data);
              if (obj['code'] == 0) {
                // 删除成功
                BlackListUtils.removeBlackId(authorId);
                queryBlackList();
              } else {
                showResultDialog("操作失败：${obj['msg']}");
              }
            }
          },
          params: params,
          errorCallback: (e) {
            print("delete from black error: $e");
            Navigator.of(context).pop();
            showResultDialog("网络请求失败：$e");
          });
      }
    });
  }

  showResultDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) {
        return new AlertDialog(
          title: new Text('提示'),
          content: new Text(msg),
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                '确定',
                style: new TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }

  showSetFreeDialog(item) {
    String name = Utf8Utils.decode(item['authorname']);
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return new AlertDialog(
          title: new Text('提示'),
          content: new Text('确定要把\"$name\"放出小黑屋吗？'),
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                '确定',
                style: new TextStyle(color: Colors.red),
              ),
              onPressed: () {
                deleteFromBlack(item['authorid']);
              },
            )
          ],
        );
      });
  }

  Widget getBody() {
    if (!isLogin) {
      return new Center(
        child: new InkWell(
          child: new Container(
            padding: const EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
            child: new Text("去登录"),
            decoration: new BoxDecoration(
                border: new Border.all(color: Colors.black),
                borderRadius: new BorderRadius.all(new Radius.circular(5.0))
            ),
          ),
          onTap: () async {
            final result = await Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) {
              return LoginPage();
            }));
            if (result != null && result == "refresh") {
              // 通知动弹页面刷新
              Constants.eventBus.fire(new LoginEvent());
              getUserInfo();
            }
          },
        ),
      );
    }
    if (blackDataList == null) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else if (blackDataList.length == 0) {
      return new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text("小黑屋中没人..."),
            new Text("长按动弹列表即可往小黑屋中加人")
          ],
        ),
      );
    }
    return new GridView.count(
      crossAxisCount: 3,
      children: new List.generate(blackDataList.length, (index) {
        String name = Utf8Utils.decode(blackDataList[index]['authorname']);
        return new Container(
          margin: const EdgeInsets.all(2.0),
          color: Colors.black,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                width: 45.0,
                height: 45.0,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  image: new DecorationImage(
                      image: new NetworkImage(
                          "${blackDataList[index]['authoravatar']}"),
                      fit: BoxFit.cover),
                  border: new Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
              ),
              new Container(
                margin: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                child:
                    new Text(name, style: new TextStyle(color: Colors.white)),
              ),
              new InkWell(
                child: new Container(
                  padding: const EdgeInsets.fromLTRB(8.0, 5.0, 5.0, 8.0),
                  child: new Text(
                    "放我出去",
                    style: btnStyle,
                  ),
                  decoration: new BoxDecoration(
                      border: new Border.all(color: Colors.white),
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(5.0))),
                ),
                onTap: () {
                  showSetFreeDialog(blackDataList[index]);
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("动弹小黑屋", style: new TextStyle(color: Colors.white)),
        iconTheme: new IconThemeData(color: Colors.white),
      ),
      body: new Padding(
        padding: const EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 0.0),
        child: getBody(),
      ),
    );
  }
}
