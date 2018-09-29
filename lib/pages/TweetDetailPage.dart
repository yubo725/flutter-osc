import 'package:flutter/material.dart';
import '../util/NetUtils.dart';
import '../api/Api.dart';
import '../constants/Constants.dart';
import 'dart:convert';
import '../widgets/CommonEndLine.dart';
import '../util/DataUtils.dart';

// 动弹详情

class TweetDetailPage extends StatefulWidget {
  Map<String, dynamic> tweetData;

  TweetDetailPage({Key key, this.tweetData}):super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new TweetDetailPageState(tweetData: tweetData);
  }
}

class TweetDetailPageState extends State<TweetDetailPage> {

  Map<String, dynamic> tweetData;
  List commentList;
  RegExp regExp1 = new RegExp("</.*>");
  RegExp regExp2 = new RegExp("<.*>");
  TextStyle subtitleStyle = new TextStyle(
      fontSize: 12.0,
      color: const Color(0xFFB5BDC0)
  );
  TextStyle contentStyle = new TextStyle(
      fontSize: 15.0,
      color: Colors.black
  );
  num curPage = 1;
  ScrollController _controller = new ScrollController();
  TextEditingController _inputController = new TextEditingController();

  TweetDetailPageState({Key key, this.tweetData});

  // 获取动弹的回复
  getReply(bool isLoadMore) {
    DataUtils.isLogin().then((isLogin) {
      if (isLogin) {
        DataUtils.getAccessToken().then((token) {
          if (token == null || token.length == 0) {
            return;
          }
          Map<String, String> params = new Map();
          var id = this.tweetData['id'];
          params['id'] = '$id';
          params['catalog'] = '3';// 3是动弹评论
          params['access_token'] = token;
          params['page'] = '$curPage';
          params['pageSize'] = '20';
          params['dataType'] = 'json';
          NetUtils.get(Api.COMMENT_LIST, params: params).then((data) {
            setState(() {
              if (!isLoadMore) {
                commentList = json.decode(data)['commentList'];
                if (commentList == null) {
                  commentList = new List();
                }
              } else {
                // 加载更多数据
                List list = new List();
                list.addAll(commentList);
                list.addAll(json.decode(data)['commentList']);
                if (list.length >= tweetData['commentCount']) {
                  list.add(Constants.END_LINE_TAG);
                }
                commentList = list;
              }
            });
          });
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getReply(false);
    _controller.addListener(() {
      var max = _controller.position.maxScrollExtent;
      var pixels = _controller.position.pixels;
      if (max == pixels && commentList.length < tweetData['commentCount']) {
        // scroll to end, load next page
        curPage++;
        getReply(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var _body = commentList == null ? new Center(
      child: new CircularProgressIndicator(),
    ) : new ListView.builder(
      itemCount: commentList.length == 0 ? 1 : commentList.length * 2,
      itemBuilder: renderListItem,
      controller: _controller,
    );
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("动弹详情", style: new TextStyle(color: Colors.white)),
        iconTheme: new IconThemeData(color: Colors.white),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.send),
            onPressed: () {
              // 回复楼主
              showReplyBottomView(context, true);
            },
          )
        ],
      ),
      body: _body
    );
  }

  Widget renderListItem(BuildContext context, int i) {
    if (i == 0) {
      return getTweetView(this.tweetData);
    }
    i -= 1;
    if (i.isOdd) {
      return new Divider(height: 1.0,);
    }
    i ~/= 2;
    return _renderCommentRow(context, i);
  }

  // 渲染评论列表
  _renderCommentRow(context, i) {
    var listItem = commentList[i];
    if (listItem is String && listItem == Constants.END_LINE_TAG) {
      return new CommonEndLine();
    }
    String avatar = listItem['commentPortrait'];
    String author = listItem['commentAuthor'];
    String date = listItem['pubDate'];
    String content = listItem['content'];
    content = clearHtmlContent(content);
    var row = new Row(
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.all(10.0),
          child: new Image.network(avatar, width: 35.0, height: 35.0,)
        ),
        new Expanded(
          child: new Container(
            margin: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
            child: new Column(
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new Text(author, style: new TextStyle(color: const Color(0xFF63CA6C)),),
                    ),
                    new Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                        child: new Text(date, style: subtitleStyle,)
                    )
                  ],
                ),
                new Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                            child: new Text(content, style: contentStyle,)
                        )
                      ],
                    )
                )
              ],
            ),
          )
        )
      ],
    );
    return new Builder(
      builder: (ctx) {
        return new InkWell(
          onTap: () {
            showReplyBottomView(ctx, false, data: listItem);
          },
          child: row,
        );
      },
    );
  }

  showReplyBottomView(ctx, bool isMainFloor, {data}) {
    String title;
    String authorId;
    if (isMainFloor) {
      title = "@${tweetData['author']}";
      authorId = "${tweetData['authorid']}";
    } else {
      title = "@${data['commentAuthor']}";
      authorId = "${data['commentAuthorId']}";
    }
    print("authorId = $authorId");
    showModalBottomSheet(
      context: ctx,
      builder: (sheetCtx) {
        return new Container(
          height: 230.0,
          padding: const EdgeInsets.all(20.0),
          child: new Column(
            children: <Widget>[
              new Row(
                children: <Widget>[
                  new Text(isMainFloor ? "回复楼主" : "回复"),
                  new Expanded(child: new Text(title, style: new TextStyle(color: const Color(0xFF63CA6C)),)),
                  new InkWell(
                    child: new Container(
                      padding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                      decoration: new BoxDecoration(
                        border: new Border.all(
                          color: const Color(0xFF63CA6C),
                          width: 1.0,
                        ),
                        borderRadius: new BorderRadius.all(new Radius.circular(6.0))
                      ),
                      child: new Text("发送", style: new TextStyle(color: const Color(0xFF63CA6C)),),
                    ),
                    onTap: () {
                      // 发送回复
                      sendReply(authorId);
                    },
                  )
                ],
              ),
              new Container(
                height: 10.0,
              ),
              new TextField(
                maxLines: 5,
                controller: _inputController,
                decoration: new InputDecoration(
                  hintText: "说点啥～",
                  hintStyle: new TextStyle(
                      color: const Color(0xFF808080)
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
                  )
                ),
              )
            ],
          )
        );
      }
    );
  }

  void sendReply(authorId) {
    String replyStr = _inputController.text;
    if (replyStr == null || replyStr.length == 0 || replyStr.trim().length == 0) {
      return;
    } else {
      DataUtils.isLogin().then((isLogin) {
        if (isLogin) {
          DataUtils.getAccessToken().then((token) {
            Map<String, String> params = new Map();
            params['access_token'] = token;
            params['id'] = "${tweetData['id']}";
            print("id: ${tweetData['id']}");
            params['catalog'] = "3";
            params['content'] = replyStr;
            params['authorid'] = "$authorId";
            print("authorId: $authorId");
            params['isPostToMyZone'] = "0";
            params['dataType'] = "json";
            NetUtils.get(Api.COMMENT_REPLY, params: params).then((data) {
              if (data != null) {
                var obj = json.decode(data);
                var error = obj['error'];
                if (error != null && error == '200') {
                  // 回复成功
                  Navigator.of(context).pop();
                  getReply(false);
                }
              }
            });
          });
        }
      });
    }
  }

  Widget getTweetView(Map<String, dynamic> listItem) {
    var authorRow = new Row(
      children: <Widget>[
        new Container(
          width: 35.0,
          height: 35.0,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
            image: new DecorationImage(
                image: new NetworkImage(listItem['portrait']),
                fit: BoxFit.cover
            ),
            border: new Border.all(
              color: Colors.white,
              width: 2.0,
            ),
          ),
        ),
        new Padding(
            padding: const EdgeInsets.fromLTRB(6.0, 0.0, 0.0, 0.0),
            child: new Text(listItem['author'], style: new TextStyle(
              fontSize: 16.0,
            ))
        ),
        new Expanded(
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Text('${listItem['commentCount']}', style: subtitleStyle,),
              new Image.asset('./images/ic_comment.png', width: 20.0, height: 20.0,)
            ],
          ),
        )
      ],
    );
    var _body = listItem['body'];
    _body = clearHtmlContent(_body);
    var contentRow = new Row(
      children: <Widget>[
        new Expanded(child: new Text(_body),)
      ],
    );
    var timeRow = new Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Text(listItem['pubDate'], style: subtitleStyle,)
      ],
    );
    var columns = <Widget>[
      new Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 2.0),
        child: authorRow,
      ),
      new Padding(
        padding: const EdgeInsets.fromLTRB(52.0, 0.0, 10.0, 0.0),
        child: contentRow,
      ),
    ];
    String imgSmall = listItem['imgSmall'];
    if (imgSmall != null && imgSmall.length > 0) {
      // 动弹中有图片
      List<String> list = imgSmall.split(",");
      List<String> imgUrlList = new List<String>();
      for (String s in list) {
        if (s.startsWith("http")) {
          imgUrlList.add(s);
        } else {
          imgUrlList.add("https://static.oschina.net/uploads/space/" + s);
        }
      }
      List<Widget> imgList = [];
      List rows = [];
      num len = imgUrlList.length;
      for (var row = 0; row < getRow(len); row++) {
        List<Widget> rowArr = [];
        for (var col = 0; col < 3; col++) {
          num index = row * 3 + col;
          num screenWidth = MediaQuery.of(context).size.width;
          double cellWidth = (screenWidth - 100) / 3;
          if (index < len) {
            rowArr.add(new Padding(
              padding: const EdgeInsets.all(2.0),
              child: new Image.network(imgUrlList[index], width: cellWidth, height: cellWidth),
            ));
          }
        }
        rows.add(rowArr);
      }
      for (var row in rows) {
        imgList.add(new Row(
          children: row,
        ));
      }
      columns.add(new Padding(
        padding: const EdgeInsets.fromLTRB(52.0, 5.0, 10.0, 0.0),
        child: new Column(
          children: imgList,
        ),
      ));
    }
    columns.add(new Padding(
      padding: const EdgeInsets.fromLTRB(52.0, 10.0, 10.0, 6.0),
      child: timeRow,
    ));
    columns.add(new Divider(height: 5.0,));
    columns.add(new Container(
      margin: const EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 0.0),
      child: new Row(
        children: <Widget>[
          new Container(
            width: 4.0,
            height: 20.0,
            color: const Color(0xFF63CA6C),
          ),
          new Expanded(
            flex: 1,
            child: new Container(
              height: 20.0,
              color: const Color(0xFFECECEC),
              child: new Text("评论列表", style: new TextStyle(color: const Color(0xFF63CA6C)),)
            ),
          )
        ],
      ),
    ));
    return new Column(
      children: columns,
    );
  }

  int getRow(int n) {
    int a = n % 3;
    int b = n ~/ 3;
    if (a != 0) {
      return b + 1;
    }
    return b;
  }

  // 去掉文本中的html代码
  String clearHtmlContent(String str) {
    if (str.startsWith("<emoji")) {
      return "[emoji]";
    }
    var s = str.replaceAll(regExp1, "");
    s = s.replaceAll(regExp2, "");
    s = s.replaceAll("\n", "");
    return s;
  }
}