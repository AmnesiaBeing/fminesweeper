/*
  该文件负责扫雷中的每个砖块的内在逻辑，包括：
    是否已经被翻开
    是否被标记
    是否是地雷
    当前块的周围的地雷总数
*/

import 'package:flutter/foundation.dart';

enum TileState {
  /// 未翻开
  UNOPENED,

  /// 未翻开，标记了
  FLAGGED,

  /// 已翻开，可能是地雷
  OPENED,
}

class TileModel {
  /// 三种互斥状态
  TileState tileState;

  /// 是否是地雷
  bool isMine;

  /// 错误标记：结算模式下，显示辅助标记。
  /// 已翻开且为地雷，标记了且不是地雷
  bool isWrong;

  /// 相邻的地雷数
  int adjacentMines;

  TileModel({
    @required this.tileState,
    @required this.isMine,
    @required this.isWrong,
    this.adjacentMines = 0,
  });
}
