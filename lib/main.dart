import 'package:flutter/material.dart';
import 'package:hello_world/image_grid.dart';
import 'package:hello_world/random_words.dart';
import 'package:hello_world/refresh.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Welcome to Flutter',
      theme: new ThemeData(
        primaryColor: Colors.green,
      ),
      routes: {
        "/": (_) => new HomePage(),
        "/random": (_) => new RandomWords(),
        "/refresh": (_) => new Refresh(),
        "/images": (_) => new ImageGrid(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Demo"),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Center(
          child: new Column(
            children: <Widget>[
              new RaisedButton(
                  child: new Text("下拉刷新"),
                  onPressed: () {
                    Navigator.of(context).pushNamed("/refresh");
                  }),
              new Divider(),
              new RaisedButton(
                  child: new Text("名字生成器"),
                  onPressed: () {
                    Navigator.of(context).pushNamed("/random");
                  }),
              new Divider(),
              new RaisedButton(
                  child: new Text("图片例子"),
                  onPressed: () {
                    Navigator.of(context).pushNamed("/images");
                  })
            ],
          ),
        ),
      ),
    );
  }
}
