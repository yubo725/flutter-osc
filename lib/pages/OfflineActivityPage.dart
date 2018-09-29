import 'dart:convert';
import 'package:flutter/material.dart';
import '../util/NetUtils.dart';
import '../api/Api.dart';
import '../pages/CommonWebPage.dart';

// 线下活动
class OfflineActivityPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new OfflineActivityPageState();
  }
}

class OfflineActivityPageState extends State<OfflineActivityPage> {
  String eventTypeLatest = "latest";
  String eventTypeYch = "ych";
  String eventTypeRec = "recommend";
  int curPage = 1;

  TextStyle titleTextStyle = new TextStyle(color: Colors.black, fontSize: 18.0);

  List recData, latestData, ychData;

  @override
  void initState() {
    super.initState();
    getData(eventTypeRec);
    getData(eventTypeLatest);
    getData(eventTypeYch);
  }

  void getData(String type) {
    String url = Api.EVENT_LIST;
    url += "$type?pageIndex=$curPage&pageSize=5";
    NetUtils.get(url).then((data) {
      if (data != null) {
        var obj = json.decode(data);
        if (obj != null && obj['code'] == 0) {
          print(obj);
          setState(() {
            if (type == eventTypeRec) {
              recData = obj['msg'];
            } else if (type == eventTypeLatest) {
              latestData = obj['msg'];
            } else {
              ychData = obj['msg'];
            }
          });
        }
      }
    });
  }

  Widget getRecBody() {
    if (recData == null) {
      return new Center(child: new CircularProgressIndicator());
    } else if (recData.length == 0) {
      return new Center(child: new Text("暂无数据"));
    } else {
      return new ListView.builder(itemBuilder: _renderRecRow, itemCount: recData.length);
    }
  }

  Widget getLatestBody() {
    if (latestData == null) {
      return new Center(child: new CircularProgressIndicator());
    } else if (latestData.length == 0) {
      return new Center(child: new Text("暂无数据"));
    } else {
      return new ListView.builder(itemBuilder: _renderLatestRow, itemCount: latestData.length);
    }
  }

  Widget getYchBody() {
    if (ychData == null) {
      return new Center(child: new CircularProgressIndicator());
    } else if (ychData.length == 0) {
      return new Center(child: new Text("暂无数据"));
    } else {
      return new ListView.builder(itemBuilder: _renderYchRow, itemCount: ychData.length);
    }
  }

  Widget getCard(itemData) {
    return new Card(
      child: new Column(
        children: <Widget>[
          new Image.network(itemData['cover'], fit: BoxFit.cover,),
          new Container(
            margin: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
            alignment: Alignment.centerLeft,
            child: new Text(itemData['title'], style: titleTextStyle,),
          ),
          new Container(
              margin: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
              child: new Row(
                children: <Widget>[
                  new Expanded(child: new Text(itemData['authorName']), flex: 1,),
                  new Text(itemData['timeStr'])
                ],
              )
          )
        ],
      ),
    );
  }

  Widget _renderRecRow(BuildContext ctx, int i) {
    Map itemData = recData[i];
    return new InkWell(
      child: getCard(itemData),
      onTap: () {
        _showDetail(itemData['detailUrl']);
      },
    );
  }

  Widget _renderLatestRow(BuildContext ctx, int i) {
    Map itemData = latestData[i];
    return new InkWell(
      child: getCard(itemData),
      onTap: () {
        _showDetail(itemData['detailUrl']);
      },
    );
  }

  Widget _renderYchRow(BuildContext ctx, int i) {
    Map itemData = ychData[i];
    return new InkWell(
      child: getCard(itemData),
      onTap: () {
        _showDetail(itemData['detailUrl']);
      },
    );
  }

  _showDetail(detailUrl) {
    Navigator.of(context).push(new MaterialPageRoute(
      builder: (ctx) {
        return new CommonWebPage(title: '活动详情', url: detailUrl);
      }
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("线下活动", style: new TextStyle(color: Colors.white)),
        iconTheme: new IconThemeData(color: Colors.white),
      ),
      body: new DefaultTabController(
        length: 3,
        child: new Scaffold(
            appBar: new TabBar(
              tabs: <Widget>[
                new Tab(
                  text: "强力推荐",
                ),
                new Tab(
                  text: "最新活动",
                ),
                new Tab(
                  text: "源创会",
                )
              ],
            ),
            body: new TabBarView(
              children: <Widget>[
                getRecBody(),
                getLatestBody(),
                getYchBody()
              ],
            )),
      ),
    );
  }
}
