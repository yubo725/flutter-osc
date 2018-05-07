import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum CircleImageType {network, asset}

class CircleImage extends StatefulWidget {
  double width;
  double height;
  String path;
  CircleImageType type; // network, asset

  CircleImage({@required this.width, @required this.height, @required this.path, @required this.type});

  @override
  State<StatefulWidget> createState() {
    return null;
  }
}

class CircleImageState extends State<CircleImage> {
  @override
  Widget build(BuildContext context) {
    var img;
    if (widget.type == CircleImageType.network) {
      img = new Image.network(widget.path, width: widget.width, height: widget.height);
    } else {
      img = new Image.asset(widget.path, width: widget.width, height: widget.height);
    }
    return new Container(
      width: widget.width,
      height: widget.height,
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
        image: new DecorationImage(
            image: img,
            fit: BoxFit.cover
        ),
        border: new Border.all(
          color: Colors.white,
          width: 2.0,
        ),
      ),
    );
  }
}