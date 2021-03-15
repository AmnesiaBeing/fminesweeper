/*
  该文件负责扫雷中的每个砖块的图形，对鼠标手势，包括：
    鼠标经过、鼠标左右单击、鼠标左右同时按下
  作出反应。
  每一个砖块的大小根据当前窗口大小而定，且具有最小值24。
*/

import 'package:flutter/material.dart';
import '../models/tile_model.dart';

class Tile extends StatefulWidget {
  const Tile({
    Key key,
    @required this.model,
    @required this.onOpen,
    @required this.onSuperOpen,
    @required this.onFlag,
  })  : assert(model != null && onOpen != null && onFlag != null),
        super(key: key);

  final TileModel model;
  final Function() onOpen;
  final Function() onSuperOpen;
  final Function() onFlag;

  @override
  _TileState createState() => _TileState();
}

class _TileState extends State<Tile> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(0.5),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: GestureDetector(
          onDoubleTap: widget.onSuperOpen,
          onTap: widget.onOpen,
          onSecondaryTap: widget.onFlag,
          onLongPress: widget.onFlag,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Material(
              color: _getBackgroundColor(),
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) =>
                      _getBlockContent(constraints),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getBlockContent(BoxConstraints constraints) {
    final iconSize = constraints.biggest.height - 1.0;

    Widget child;

    if (widget.model.tileState == TileState.FLAGGED) {
      child = Icon(Icons.flag, color: Colors.red, size: iconSize);
    } else if (widget.model.tileState == TileState.OPENED) {
      if (widget.model.isMine) {
        child = Stack(
          children: <Widget>[
            Opacity(
              opacity: 0.5,
              // 使用gps_fixed看起来像个地雷
              child: Icon(widget.model.isMine ? Icons.gps_fixed : Icons.flag,
                  size: iconSize),
            ),
            Icon(Icons.close, size: iconSize + 1.0, color: Colors.red),
          ],
        );
      } else {
        child = widget.model.adjacentMines > 0
            ? Text('${widget.model.adjacentMines}')
            : Container();
      }
    } else {
      child = Container();
    }

    return child;
  }

  Color _getBackgroundColor() {
    bool isLighter = widget.model.tileState == TileState.OPENED ||
        (_isHovering && !(widget.model.tileState == TileState.FLAGGED));

    return isLighter ? Colors.grey[300] : Colors.grey[400];
  }
}
