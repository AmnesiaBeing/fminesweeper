import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:fminesweeper/models/tile_model.dart';

/// 游戏状态机，刚开始，运行中，赢了，输了
enum GameState {
  /// 为了达成“在第一次点开时布置雷区”的目的，使用一个标志位表示这个“第一次”
  STARTING,
  RUNNING,
  LOST,
  WIN
}

/// 扫雷游戏模型，遵循GUI设计中的View-ViewModel设计方法
/// 使用flutter中的ChangeNotifer使GUI信息发生变化
class GameModel with ChangeNotifier {
  // 类构造函数，初始化所有方块
  GameModel() {
    _resetTiles();
  }

  // 一些内部常数，本游戏只做高级难度
  int _rows = 16;
  int _cols = 30;
  int _mines = 99;

  // 上述内部常数的对外提供方式，只读不写
  int get rows => _rows;
  int get cols => _cols;
  int get totalTiles => _rows * _cols;

  // 内部变量，已经翻开的方块数量
  int _opened = 0;
  int get tileOpened => _opened;

  /// 未翻开的方块数量
  int get tilesRemaining => totalTiles - _opened;

// 内部变量，标记数量
  int _flagged = 0;
// 内部变量，正确的标记数量
  int _improperlyFlagged = 0;

  /// 游戏状态
  GameState get gameState => _gameState;
  GameState _gameState = GameState.STARTING;

  /// 存储所有方块的ViewModel
  List<List<TileModel>> get tiles => _tiles;
  List<List<TileModel>> _tiles;

  /// TODO: 游戏的计时功能

  /// 处于坐标xy的方块被按下的执行函数
  /// 1. 判断是否可以按下，游戏状态是否为已经有结果的状态，如果已经出结果了，不管
  /// 2. 判断游戏是否是第一次运行，如果是则布置地雷
  /// 3. 翻开当前位置地雷数量
  /// 4. 如果当前位置是地雷，则游戏结束，失败
  /// 5. 如果当前位置附近地雷数量为0，搜索周围8个方向重复执行该函数，直到递归结束
  /// 6. 如果剩余未翻开的数量与总雷数相等，游戏结束，胜利
  /// 7. 完成所有操作后，通知GUI更新
  void onOpen(int x, int y) {
    final tile = _tiles[x][y];

    if (tile.tileState != TileState.UNOPENED ||
        _gameState == GameState.WIN ||
        _gameState == GameState.LOST) {
      return;
    }

    // 首先，布置地雷；然后，计算所有附近的地雷数量
    if (_gameState == GameState.STARTING) {
      _placeMines(x, y);
      _getNumAdjacentMines();
    }

    _onOpen(x, y);

    notifyListeners();
  }

  void _onOpen(int x, int y) {
    final tile = _tiles[x][y];
    tile.tileState = TileState.OPENED;

    if (tile.isMine) {
      _endGame(false, losingTile: <int>[x, y]);
    } else {
      // 如果当前附近地雷数量为0，则翻开附近的所有方块
      if (tile.adjacentMines == 0) {
        _visitAllAdjacentMines(x, y);
      }
    }

    if (tilesRemaining == _mines) {
      _endGame(true);
    }
  }

  /// 快捷翻开函数
  /// 如果当前格子已翻开，且周围标记的数量等于当前格子显示周围雷的数量
  /// 对周围的未翻开的格子执行翻开操作
  void onSuperOpen(int x, int y) {
    final tile = _tiles[x][y];

    if (tile.tileState != TileState.OPENED ||
        _gameState == GameState.LOST ||
        _gameState == GameState.WIN) return;

    _visitAllAdjacentMines(x, y);
  }

  /// 放置一个雷区标志的执行函数
  /// 1. 判断是否可以按下（游戏状态，是否已经被翻开）
  /// 2. 判断游戏是否第一次运行
  /// 3. 标记当前位置或者取消标记当前位置
  /// 4. 如果所有标记位置正确，游戏胜利
  void onFlag(int x, int y) {
    final tile = _tiles[x][y];

    if (tile.tileState == TileState.OPENED ||
        _gameState == GameState.LOST ||
        _gameState == GameState.WIN) return;

    if (tile.tileState == TileState.FLAGGED) {
      _flagged--;
      if (!tile.isMine) _improperlyFlagged--;
      tile.tileState = TileState.UNOPENED;
    } else {
      _flagged++;
      if (!tile.isMine) _improperlyFlagged++;
      tile.tileState = TileState.FLAGGED;
    }

    if (_improperlyFlagged == 0 && _flagged == _mines) {
      _endGame(true);
    }

    notifyListeners();
  }

  /// 重启游戏，初始化所有变量
  void restart() {
    _gameState = GameState.STARTING;

    _resetTiles();
    notifyListeners();
  }

  /// 结束游戏，是否胜利，失败的理由
  void _endGame(bool hasWon, {List<int> losingTile}) {
    _gameState = hasWon ? GameState.WIN : GameState.LOST;

    _revealAllTiles(losingTile);
  }

  /// 游戏结束时将翻开所有方块
  void _revealAllTiles(List<int> losingTile) {
    _tiles
        .asMap()
        .forEach((rowIndex, row) => row.asMap().forEach((colIndex, tile) {
              tile.tileState = TileState.OPENED;
            }));
  }

  List<List<int>> kBfsDirections = [
    [-1, -1],
    [-1, 0],
    [-1, 1],
    [0, -1],
    [0, 1],
    [1, -1],
    [1, 0],
    [1, 1],
  ];

  void _getNumAdjacentMines() {
    int _getNumAdjacentMinesAtRC(int x, int y) {
      // 当前方块是地雷就不算了
      if (_tiles[x][y].isMine) return 0;
      int adjacent = 0;
      kBfsDirections.forEach((List<int> dir) {
        final newX = x + dir[0];
        final newY = y + dir[1];
        if (_isInBounds(newX, newY) && _tiles[newX][newY].isMine) {
          adjacent++;
        }
      });
      return adjacent;
    }

    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        _tiles[r][c].adjacentMines = _getNumAdjacentMinesAtRC(r, c);
      }
    }
  }

  void _visitAllAdjacentMines(int x, int y) {
    kBfsDirections.forEach((List<int> dir) {
      final newX = x + dir[0];
      final newY = y + dir[1];
      if (_isInBounds(newX, newY) &&
          !(_tiles[newX][newY].tileState == TileState.OPENED)) {
        _onOpen(newX, newY);
      }
    });
  }

  bool _isInBounds(int x, int y) => x >= 0 && x < rows && y >= 0 && y < cols;

  // 重置所有方块
  void _resetTiles() {
    _tiles = List.generate(
        _rows,
        (x) => List.generate(
              _cols,
              (y) => TileModel(
                tileState: TileState.UNOPENED,
                isMine: false,
                adjacentMines: 0,
              ),
            ));
    notifyListeners();
  }

  // The seedX and seedY coordinates are used to make sure that no mine is
  // placed on the clicked tile or any adjacent tile.
  void _placeMines(int seedX, int seedY) {
    final List<Set> mines = List.generate(_rows, (_) => <int>{});

    var numMines = 0;
    final rand = Random();
    while (numMines < _mines) {
      int x = rand.nextInt(_rows);
      int y = rand.nextInt(_cols);
      if (!(mines[x].contains(y) || _isInSafeZone(x, y, seedX, seedY))) {
        mines[x].add(y);
        numMines++;
      }
    }

    _tiles = List.generate(
      _rows,
      (x) => List.generate(
        _cols,
        (y) => TileModel(
          tileState: TileState.UNOPENED,
          isMine: mines[x].contains(y),
        ),
      ),
    );

    _gameState = GameState.RUNNING;

    notifyListeners();
  }

  bool _isInSafeZone(int x, int y, int safeX, int safeY) =>
      (x - safeX).abs() <= 1 && (y - safeY).abs() <= 1;
}
