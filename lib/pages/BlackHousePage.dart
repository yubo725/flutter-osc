import 'package:flutter/material.dart';
import 'package:flutter_osc/constants/Constants.dart';
import 'package:flutter_osc/events/LoginEvent.dart';
import 'package:flutter_osc/pages/NewLoginPage.dart';
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
    return BlackHousePageState();
  }
}

class BlackHousePageState extends State<BlackHousePage> {
  bool isLogin = true;
  List blackDataList;
  TextStyle btnStyle = TextStyle(color: Colors.white, fontSize: 12.0);

  BlackHousePageState() {
    queryBlackList();
  }

  queryBlackList() {
    DataUtils.getUserInfo().then((userInfo) {
      if (userInfo != null) {
        String url = Api.queryBlack;
        url += "/${userInfo.id}";
        NetUtils.get(url).then((data) {
          if (data != null) {
            var obj = json.decode(data);
            if (obj['code'] == 0) {
              setState(() {
                blackDataList = obj['msg'];
              });
            }
          }
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
    Map<String, String> params = Map();
    params['access_token'] = accessToken;
    NetUtils.get(Api.userInfo, params: params).then((data) {
      if (data != null) {
        var map = json.decode(data);
        DataUtils.saveUserInfo(map).then((userInfo) {
          queryBlackList();
        });
      }
    });
  }

  // 从黑名单中删除
  deleteFromBlack(authorId) {
    DataUtils.getUserInfo().then((userInfo) {
      if (userInfo != null) {
        String userId = "${userInfo.id}";
        Map<String, String> params = Map();
        params['userid'] = userId;
        params['authorid'] = "$authorId";
        NetUtils.get(Api.deleteBlack, params: params).then((data) {
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
        }).catchError((e) {
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
        return AlertDialog(
          title: Text('提示'),
          content: Text(msg),
          actions: <Widget>[
            FlatButton(
              child: Text(
                '确定',
                style: TextStyle(color: Colors.red),
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
        return AlertDialog(
          title: Text('提示'),
          content: Text('确定要把\"$name\"放出小黑屋吗？'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                '确定',
                style: TextStyle(color: Colors.red),
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
      return Center(
        child: InkWell(
          child: Container(
            padding: const EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
            child: Text("去登录"),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(5.0))
            ),
          ),
          onTap: () async {
            final result = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
              return NewLoginPage();
            }));
            if (result != null && result == "refresh") {
              // 通知动弹页面刷新
              Constants.eventBus.fire(LoginEvent());
              getUserInfo();
            }
          },
        ),
      );
    }
    if (blackDataList == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (blackDataList.length == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("小黑屋中没人..."),
            Text("长按动弹列表即可往小黑屋中加人")
          ],
        ),
      );
    }
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(blackDataList.length, (index) {
        String name = Utf8Utils.decode(blackDataList[index]['authorname']);
        return Container(
          margin: const EdgeInsets.all(2.0),
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 45.0,
                height: 45.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  image: DecorationImage(
                      image: NetworkImage(
                          "${blackDataList[index]['authoravatar']}"),
                      fit: BoxFit.cover),
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                child:
                    Text(name, style: TextStyle(color: Colors.white)),
              ),
              InkWell(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8.0, 5.0, 5.0, 8.0),
                  child: Text(
                    "放我出去",
                    style: btnStyle,
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius:
                          BorderRadius.all(Radius.circular(5.0))),
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
    return Scaffold(
      appBar: AppBar(
        title: Text("动弹小黑屋", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 0.0),
        child: getBody(),
      ),
    );
  }
}
