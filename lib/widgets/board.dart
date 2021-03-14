import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fminesweeper/widgets/tile.dart';
import 'package:fminesweeper/models/game_model.dart';

// 扫雷棋盘的包裹组建
class MineSweeperBoardWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameModel>(
      builder: (context, model, child) {
        double tileWidth =
            (MediaQuery.of(context).orientation == Orientation.landscape)
                ? (MediaQuery.of(context).size.height - 16.0) / model.rows
                : (MediaQuery.of(context).size.width - 16.0) / model.cols;
        return Card(
          child: Container(
            width: tileWidth * model.cols + 16.0,
            height: tileWidth * model.rows + 16.0,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                MineSweeperBoard(model: model),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 扫雷棋盘，只适配电脑屏幕，高16×宽30，共99个雷
class MineSweeperBoard extends StatelessWidget {
  const MineSweeperBoard({Key key, @required this.model}) : super(key: key);

  final GameModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36.0 * model.rows,
      width: 36.0 * model.cols,
      child: GridView.count(
        crossAxisCount: model.cols,
        physics: NeverScrollableScrollPhysics(),
        children: generateChildren(model),
      ),
    );
  }

  List<Widget> generateChildren(GameModel model) {
    return List.generate(
      model.rows,
      (x) => List.generate(
        model.cols,
        (y) => Tile(
          model: model.tiles[x][y],
          onOpen: () => model.onOpen(x, y),
          onSuperOpen: () => model.onSuperOpen(x, y),
          onFlag: () => model.onFlag(x, y),
        ),
      ),
    ).expand((e) => e).toList();
  }
}
