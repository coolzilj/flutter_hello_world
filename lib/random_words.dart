import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class RandomWords extends StatefulWidget {
  @override
  createState() => RandomWordsState();
}

class RandomWordsState extends State<RandomWords>
    with TickerProviderStateMixin {
  final _suggestions = <WordPair>[];
  final _suggestionRows = <SuggestionRow>[];
  SavedPairsModel _model;
  final pairEveryTime = 10;

  @override
  void initState() {
    _model = SavedPairsModel();
    super.initState();
  }

  @override
  void dispose() {
    for (SuggestionRow row in _suggestionRows)
      row.animationController.dispose();
    super.dispose();
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();
        final index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(pairEveryTime));
        }
        return _buildRow(_suggestions[index], index);
      },
    );
  }

  Widget _buildRow(WordPair pair, int index) {
    final ms = 0 + index % pairEveryTime * 100;
    // print(ms);
    SuggestionRow row = SuggestionRow(
        pair: pair,
        index: index,
        animationController: AnimationController(
          duration: Duration(milliseconds: ms),
          vsync: this,
        ));
    _suggestionRows.add(row);
    row.animationController.forward();
    return row;
  }

  void _pushSaved(model) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        final tiles = model.pairs.map<Widget>((pair) {
          return ListTile(
            title: Text(
              pair.asPascalCase,
              style: TextStyle(fontSize: 19.0),
            ),
          );
        });

        final divied = ListTile
            .divideTiles(
              context: context,
              tiles: tiles,
            )
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: Text("收藏"),
          ),
          body: ListView(children: divied),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: _model,
      child: Scaffold(
        appBar: AppBar(
          title: Text('名字生成器'),
          actions: <Widget>[
            ScopedModelDescendant<SavedPairsModel>(
                rebuildOnChange: false,
                builder: (context, _, model) => IconButton(
                    icon: Icon(Icons.list),
                    onPressed: () => _pushSaved(model))),
          ],
        ),
        body: _buildSuggestions(),
        floatingActionButton: ScopedModelDescendant<SavedPairsModel>(
          rebuildOnChange: false,
          builder: (context, _, model) => FloatingActionButton(
                onPressed: () => model.clear(),
                child: Icon(Icons.clear),
              ),
        ),
      ),
    );
  }
}

class SuggestionRow extends StatelessWidget {
  final WordPair pair;
  final AnimationController animationController;
  final int index;

  SuggestionRow({this.pair, this.animationController, this.index});

  // // 旋转
  // @override
  // Widget build(BuildContext context) {
  //   return ScopedModelDescendant<SavedPairsModel>(builder: (context, _, model) {
  //     final alreadySaved = model.pairs.contains(pair);
  //     return RotationTransition(
  //       turns: CurvedAnimation(parent: animationController, curve: Curves.linear),
  //       child: ListTile(
  //         title: Text(
  //           index.toString() + " - " + pair.asPascalCase,
  //           style: TextStyle(fontSize: 19.0),
  //         ),
  //         trailing: Icon(
  //           alreadySaved ? Icons.favorite : Icons.favorite_border,
  //           color: alreadySaved ? Colors.red : null,
  //         ),
  //         onTap: () {
  //           if (alreadySaved) {
  //             model.remove(pair);
  //           } else {
  //             model.add(pair);
  //           }
  //         },
  //       ),
  //     );
  //   });
  // }

  // 放大
  // @override
  // Widget build(BuildContext context) {
  //   return ScopedModelDescendant<SavedPairsModel>(builder: (context, _, model) {
  //     final alreadySaved = model.pairs.contains(pair);
  //     return SizeTransition(
  //       sizeFactor:
  //           CurvedAnimation(curve: Curves.easeInOut, parent: animationController),
  //       child: ListTile(
  //         title: Text(
  //           index.toString() + " - " + pair.asPascalCase,
  //           style: TextStyle(fontSize: 19.0),
  //         ),
  //         trailing: Icon(
  //           alreadySaved ? Icons.favorite : Icons.favorite_border,
  //           color: alreadySaved ? Colors.red : null,
  //         ),
  //         onTap: () {
  //           if (alreadySaved) {
  //             model.remove(pair);
  //           } else {
  //             model.add(pair);
  //           }
  //         },
  //       ),
  //     );
  //   });
  // }

  // 移动
  @override
  Widget build(BuildContext context) {
    final curve =
        CurvedAnimation(curve: Curves.easeInOut, parent: animationController);
    var position = Tween<Offset>(
      begin: Offset(0.5, 0.0), // Offset(0.0, 1.0) 从下到上
      end: Offset.zero,
    ).animate(curve);

    return ScopedModelDescendant<SavedPairsModel>(builder: (context, _, model) {
      final alreadySaved = model.pairs.contains(pair);
      return SlideTransition(
        position: position,
        child: ListTile(
          title: Text(
            index.toString() + " - " + pair.asPascalCase,
            style: TextStyle(fontSize: 19.0),
          ),
          trailing: Icon(
            alreadySaved ? Icons.favorite : Icons.favorite_border,
            color: alreadySaved ? Colors.red : null,
          ),
          onTap: () {
            if (alreadySaved) {
              model.remove(pair);
            } else {
              model.add(pair);
            }
          },
        ),
      );
    });
  }
}

/////////////////////////////////////
// 方法一：InheritedWidget
// InheritedWidget 的方式只能从上往下传，如果想从下往上传就杯具了，像这个 save 必须在 listtile 里点击，然后更改上面的 saved
// 这时候只能考虑 scoped model
//
// class SavedPairsProvider extends InheritedWidget {
//   final SavedPairs saved;
//   final Widget child;
//   SavedPairsProvider({this.child, this.saved}) : super(child: child);

//   static SavedPairsProvider of(BuildContext context) =>
//       context.inheritFromWidgetOfExactType(SavedPairsProvider);

//   @override
//   bool updateShouldNotify(SavedPairsProvider oldWidget) {
//     return saved != oldWidget.saved;
//   }
// }

// class SavedPairs {
//   Set<WordPair> pairs;
//   SavedPairs(this.pairs);

//   void add(WordPair pair) {
//     pairs.add(pair);
//   }

//   void remove(WordPair pair) {
//     pairs.remove(pair);
//   }

//   void clear() {
//     pairs.clear();
//   }
// }
/////////////////////////////////////

class SavedPairsModel extends Model {
  var saved = Set<WordPair>();

  Set<WordPair> get pairs => saved;

  void add(pair) {
    saved.add(pair);
    notifyListeners();
  }

  void remove(pair) {
    saved.remove(pair);
    notifyListeners();
  }

  void clear() {
    saved.clear();
    notifyListeners();
  }
}
