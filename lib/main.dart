import 'package:flutter/material.dart';
import 'package:fminesweeper/models/time_model.dart';
import 'package:provider/provider.dart';

import 'package:fminesweeper/widgets/board.dart';

import 'package:fminesweeper/models/game_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MineSweeper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    GameModel gameModel = GameModel();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GameModel>.value(value: gameModel),
        ChangeNotifierProvider<TimeModel>.value(value: gameModel.timeModel),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('扫雷-高级'),
              Consumer<TimeModel>(
                  builder: (context, model, child) =>
                      Text(model.tick.toString())),
              IconButton(
                  icon: Icon(Icons.replay),
                  onPressed: () {
                    gameModel.restart();
                  })
            ],
          ),
        ),
        body: Center(
          child: MineSweeperBoardWrapper(),
        ),
      ),
    );
  }
}
