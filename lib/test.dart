import 'package:flutter/material.dart';

final key = GlobalKey<MyStatefulWidgetOneState>();

main() {
  runApp(GlobalKeyCommunication());
}

class GlobalKeyCommunication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
      appBar: AppBar(title: Text('Global Key Communication', style: TextStyle(fontSize: 14.0),),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          MyStatefulWidgetOne(key: key),
          MyStatefulWidgetTwo(),
        ],
      ),
    );
    return new MaterialApp(
      title: 'test',
      home: scaffold,
    );
  }

}

class MyStatefulWidgetOne extends StatefulWidget {
  MyStatefulWidgetOne({ Key key }) : super(key: key);
  MyStatefulWidgetOneState createState() => MyStatefulWidgetOneState();
}

class MyStatefulWidgetOneState extends State<MyStatefulWidgetOne> {
  String _message = "Hello world!";
  String get message => _message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Container(height: 20.0,),
          Text('Widget one message: ' + _message)
        ],
      ),
    );
  }
  void updateMessage(String msg) {
    setState((){
      _message = msg;
    });
  }
}

class MyStatefulWidgetTwo extends StatefulWidget {
  MyStatefulWidgetTwoState createState() => MyStatefulWidgetTwoState();
}

class MyStatefulWidgetTwoState extends State<MyStatefulWidgetTwo> {
  String _objectOne = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Divider(),
        Text('Widget two'),
        Container(height: 20.0,),
        RaisedButton(
          child: Text("Get Current Message"),
          onPressed: () {
            setState(() {
              _objectOne = key.currentState.message;
            });
          },
        ),
        Text(_objectOne),
        RaisedButton(
          child: Text("Update Message"),
          onPressed: () {
            setState(() {
              key.currentState.updateMessage("new message");
            });
          },
        ),
      ],
    );
  }
}