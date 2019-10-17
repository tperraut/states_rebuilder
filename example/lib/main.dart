import 'package:flutter/material.dart';

import './examples/counter_app.dart' as counterApp;
import './examples/grid_counter_app.dart' as gridCounterApp;
import './state_with_mixin_builder.dart/main.dart' as stateWithMixin;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'States Rebuilder ',
      home: Scaffold(
        appBar: AppBar(
          title: Text("States Rebuilder demo"),
        ),
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  goto(Widget page, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            child: Text("Example 1: Counter app"),
            onPressed: () => goto(counterApp.App(), context),
          ),
          RaisedButton(
            child: Text("Example 2: Grid Counter app"),
            onPressed: () => goto(gridCounterApp.App(), context),
          ),
          RaisedButton(
            child: Text("StateWithMixinBuilder examples"),
            onPressed: () => goto(stateWithMixin.MyApp(), context),
          ),
        ],
      ),
    );
  }
}
