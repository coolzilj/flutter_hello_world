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
    return super.createElement();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("图片缓存"),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    Widget cacheImagesSection = new Expanded(
      child: new FutureBuilder(
        future: _getImages(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return new CircularProgressIndicator();
            default:
              if (snapshot.data != null) {
                print(snapshot.data);
                return new GridView.count(
                  crossAxisCount: 2,
                  // 如果为false，则出现 Vertical viewport was given unbounded height
                  // 如果未true，则当图片多了会出现问题，这时候需要用到 Expanded（多了可以滚动）
                  // shrinkWrap: true,
                  children: snapshot.data.map<Widget>((entity) {
                    return new Card(
                        child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        AspectRatio(
                          aspectRatio: 18 / 11,
                          child: Image.file(
                            new File(entity.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                        new Expanded(
                          child: new Padding(
                            padding: EdgeInsets.all(9.0),
                            child: new Text(
                              entity.path,
                              style: new TextStyle(fontSize: 10.0),
                            ),
                          ),
                        ),
                      ],
                    ));
                  }).toList(),
                );
              } else {
                return new Container();
              }
          }
        },
      ),
    );

    return new Stack(children: <Widget>[
      new Column(
        children: <Widget>[
          new CachedNetworkImage(
            imageUrl:
                "https://images.unsplash.com/photo-1511789421096-2b3be5f1f623?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8e2f9b6ddc7b729ef90fde26207e2f26&auto=format&fit=crop&w=1349&q=80",
            placeholder: new CircularProgressIndicator(),
            errorWidget: new Icon(Icons.error),
            width: double.infinity,
            height: 200.0,
            fit: BoxFit.cover,
          ),
          cacheImagesSection,
        ],
      ),
      new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new FractionalTranslation(
            translation: const Offset(0.0, 1.0),
            child: new FloatingActionButton(
              onPressed: () {},
              child: new Text("缓存"),
            ),
          )
        ],
      )
    ]);
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
