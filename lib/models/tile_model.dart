/*
  该文件负责扫雷中的每个砖块的内在逻辑，包括：
    是否已经被翻开
    是否被标记
    是否是地雷
    当前块的周围的地雷总数
*/

import 'package:flutter/foundation.dart';

class TileModel {
  bool isOpened;
  bool isFlagged;
  bool isMine;

  int adjacentMines;

  TileModel({
    @required this.isOpened,
    @required this.isFlagged,
    @required this.isMine,
    this.adjacentMines = 0,
  });
}
