/*
  该文件负责扫雷中的每个砖块的内在逻辑，包括：
    是否已经被翻开
    是否被标记
    是否是地雷
    当前块的周围的地雷总数
*/

import 'package:flutter/foundation.dart';

enum TileState {
  // 未翻开
  UNOPENED,
  // 未翻开，标记了
  FLAGGED,
  // 已翻开，可能是地雷
  OPENED,
}

class TileModel {
  // 三种互斥状态
  TileState tileState;
  // 是否是地雷
  bool isMine;

  // 错误标记：已翻开且为地雷，标记了且不是地雷
  // bool get isWrong =>
  //     (tileState == TileState.OPENED && isMine) ||
  //     (tileState == TileState.FLAGGED && !isMine);

  int adjacentMines;

  TileModel({
    @required this.tileState,
    @required this.isMine,
    this.adjacentMines = 0,
  });
}
