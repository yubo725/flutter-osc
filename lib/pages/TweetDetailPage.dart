import 'package:flutter/material.dart';
import '../util/NetUtils.dart';
import '../api/Api.dart';
import '../constants/Constants.dart';
import 'dart:convert';
import '../widgets/CommonEndLine.dart';
import '../util/DataUtils.dart';

// 动弹详情

class TweetDetailPage extends StatefulWidget {
  final Map<String, dynamic> tweetData;

  TweetDetailPage({Key key, this.tweetData}):super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TweetDetailPageState(tweetData: tweetData);
  }
}

class TweetDetailPageState extends State<TweetDetailPage> {

  Map<String, dynamic> tweetData;
  List commentList;
  RegExp regExp1 = RegExp("</.*>");
  RegExp regExp2 = RegExp("<.*>");
  TextStyle subtitleStyle = TextStyle(
      fontSize: 12.0,
      color: const Color(0xFFB5BDC0)
  );
  TextStyle contentStyle = TextStyle(
      fontSize: 15.0,
      color: Colors.black
  );
  num curPage = 1;
  ScrollController _controller = ScrollController();
  TextEditingController _inputController = TextEditingController();

  TweetDetailPageState({Key key, this.tweetData});

  // 获取动弹的回复
  getReply(bool isLoadMore) {
    DataUtils.isLogin().then((isLogin) {
      if (isLogin) {
        DataUtils.getAccessToken().then((token) {
          if (token == null || token.length == 0) {
            return;
          }
          Map<String, String> params = Map();
          var id = this.tweetData['id'];
          params['id'] = '$id';
          params['catalog'] = '3';// 3是动弹评论
          params['access_token'] = token;
          params['page'] = '$curPage';
          params['pageSize'] = '20';
          params['dataType'] = 'json';
          NetUtils.get(Api.commentList, params: params).then((data) {
            setState(() {
              if (!isLoadMore) {
                commentList = json.decode(data)['commentList'];
                if (commentList == null) {
                  commentList = List();
                }
              } else {
                // 加载更多数据
                List list = List();
                list.addAll(commentList);
                list.addAll(json.decode(data)['commentList']);
                if (list.length >= tweetData['commentCount']) {
                  list.add(Constants.endLineTag);
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
    var _body = commentList == null ? Center(
      child: CircularProgressIndicator(),
    ) : ListView.builder(
      itemCount: commentList.length == 0 ? 1 : commentList.length * 2,
      itemBuilder: renderListItem,
      controller: _controller,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("动弹详情", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
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
      return Divider(height: 1.0,);
    }
    i ~/= 2;
    return _renderCommentRow(context, i);
  }

  // 渲染评论列表
  _renderCommentRow(context, i) {
    var listItem = commentList[i];
    if (listItem is String && listItem == Constants.endLineTag) {
      return CommonEndLine();
    }
    String avatar = listItem['commentPortrait'];
    String author = listItem['commentAuthor'];
    String date = listItem['pubDate'];
    String content = listItem['content'];
    content = clearHtmlContent(content);
    var row = Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.network(avatar, width: 35.0, height: 35.0,)
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(author, style: TextStyle(color: const Color(0xFF63CA6C)),),
                    ),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                        child: Text(date, style: subtitleStyle,)
                    )
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: Text(content, style: contentStyle,)
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
    return Builder(
      builder: (ctx) {
        return InkWell(
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
        return Container(
          height: 230.0,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(isMainFloor ? "回复楼主" : "回复"),
                  Expanded(child: Text(title, style: TextStyle(color: const Color(0xFF63CA6C)),)),
                  InkWell(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF63CA6C),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(6.0))
                      ),
                      child: Text("发送", style: TextStyle(color: const Color(0xFF63CA6C)),),
                    ),
                    onTap: () {
                      // 发送回复
                      sendReply(authorId);
                    },
                  )
                ],
              ),
              Container(
                height: 10.0,
              ),
              TextField(
                maxLines: 5,
                controller: _inputController,
                decoration: InputDecoration(
                  hintText: "说点啥～",
                  hintStyle: TextStyle(
                      color: const Color(0xFF808080)
                  ),
                  border: OutlineInputBorder(
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
            Map<String, String> params = Map();
            params['access_token'] = token;
            params['id'] = "${tweetData['id']}";
            print("id: ${tweetData['id']}");
            params['catalog'] = "3";
            params['content'] = replyStr;
            params['authorid'] = "$authorId";
            print("authorId: $authorId");
            params['isPostToMyZone'] = "0";
            params['dataType'] = "json";
            NetUtils.get(Api.commentReply, params: params).then((data) {
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
    var authorRow = Row(
      children: <Widget>[
        Container(
          width: 35.0,
          height: 35.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
            image: DecorationImage(
                image: NetworkImage(listItem['portrait']),
                fit: BoxFit.cover
            ),
            border: Border.all(
              color: Colors.white,
              width: 2.0,
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(6.0, 0.0, 0.0, 0.0),
            child: Text(listItem['author'], style: TextStyle(
              fontSize: 16.0,
            ))
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text('${listItem['commentCount']}', style: subtitleStyle,),
              Image.asset('./images/ic_comment.png', width: 20.0, height: 20.0,)
            ],
          ),
        )
      ],
    );
    var _body = listItem['body'];
    _body = clearHtmlContent(_body);
    var contentRow = Row(
      children: <Widget>[
        Expanded(child: Text(_body),)
      ],
    );
    var timeRow = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(listItem['pubDate'], style: subtitleStyle,)
      ],
    );
    var columns = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 2.0),
        child: authorRow,
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(52.0, 0.0, 10.0, 0.0),
        child: contentRow,
      ),
    ];
    String imgSmall = listItem['imgSmall'];
    if (imgSmall != null && imgSmall.length > 0) {
      // 动弹中有图片
      List<String> list = imgSmall.split(",");
      List<String> imgUrlList = List<String>();
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
            rowArr.add(Padding(
              padding: const EdgeInsets.all(2.0),
              child: Image.network(imgUrlList[index], width: cellWidth, height: cellWidth),
            ));
          }
        }
        rows.add(rowArr);
      }
      for (var row in rows) {
        imgList.add(Row(
          children: row,
        ));
      }
      columns.add(Padding(
        padding: const EdgeInsets.fromLTRB(52.0, 5.0, 10.0, 0.0),
        child: Column(
          children: imgList,
        ),
      ));
    }
    columns.add(Padding(
      padding: const EdgeInsets.fromLTRB(52.0, 10.0, 10.0, 6.0),
      child: timeRow,
    ));
    columns.add(Divider(height: 5.0,));
    columns.add(Container(
      margin: const EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 0.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 4.0,
            height: 20.0,
            color: const Color(0xFF63CA6C),
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 20.0,
              color: const Color(0xFFECECEC),
              child: Text("评论列表", style: TextStyle(color: const Color(0xFF63CA6C)),)
            ),
          )
        ],
      ),
    ));
    return Column(
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