import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hello_world/util/filesize.dart';
import 'package:path_provider/path_provider.dart';

class ImageGrid extends StatelessWidget {
  @override
  StatelessElement createElement() {
    CacheManager.showDebugLogs = true;
//    CacheManager.getInstance().then((cache) {
//      cache
//          .getFile(
//              "http://d.hiphotos.baidu.com/baike/pic/item/1f178a82b9014a902df55272a1773912b21bee32.jpg")
//          .then((file) {
//        print(file.path);
//      });
//    });

    return super.createElement();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("图片例子"),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Column(
        children: <Widget>[
          new Text("正在展示的图片"),
          new Center(
            child: new ConstrainedBox(
              constraints: new BoxConstraints.expand(height: 100.0),
              child: new CachedNetworkImage(
                imageUrl:
                    "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1527746650&di=452fe7d5e465170bc301de2cc0c1f2e5&imgtype=jpg&er=1&src=http%3A%2F%2Fimg5q.duitang.com%2Fuploads%2Fitem%2F201410%2F11%2F20141011234806_aj3Ns.jpeg",
                placeholder: new CircularProgressIndicator(),
                errorWidget: new Icon(Icons.error),
              ),
            ),
          ),
          new Text("缓存图片"),
          new Expanded(
            child: new FutureBuilder(
              future: _getImages(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return new Text('Press button to start');
                  case ConnectionState.waiting:
                    return new Text('Awaiting result...');
                  default:
                    if (snapshot.data != null) {
                      print("not null");
                      print(snapshot.data);
                      return new GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 1.0,
                        padding: EdgeInsets.all(8.0),
                        mainAxisSpacing: 8.0,
                        // 如果为false，则出现 Vertical viewport was given unbounded height
                        // 如果未true，则当图片多了会出现问题，这时候需要用到 Expanded（多了可以滚动）
                        // shrinkWrap: false,
                        children: snapshot.data.map<Widget>((entity) {
                          return new GridTile(
                            child: new Image.file(new File(entity.path)),
                          );
                        }).toList(),
                      );
                    } else {
                      print("null");
                      return new Container();
                    }
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Future<List<FileSystemEntity>> _getImages() async {
    var directory = await getTemporaryDirectory();
    // 也许这是个bug， .../cachecache/..., 那就自己先改一下吧
    directory = new Directory(directory.path + "cache");

    final images = directory
        .listSync(
            recursive: true,
            followLinks: false) // 如果这里用 list 会返回一个 stream，这样会出现第一次加载返回空数组的问题
        .where((entity) => entity is File)
        .toList();

    for (var entity in images) {
      final len = await (entity as File).length();
      print("path: " + entity.path + ", length: " + filesize(len.toString()));
    }

    return images;
  }
}
