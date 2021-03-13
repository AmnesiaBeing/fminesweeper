import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fminesweeper/widgets/board.dart';

import 'package:fminesweeper/models/game_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MineSweeper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'MineSweeper'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider<GameModel>.value(value: GameModel()),
        ],
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0) +
                  const EdgeInsets.only(left: 32.0, right: 16.0),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      MineSweeperBoardWrapper(),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 64.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
