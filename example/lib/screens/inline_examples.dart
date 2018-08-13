import 'package:example/screens/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class InlineExamples extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const ExampleAppBar(
            title: "Inline Examples",
            showGoBack: true,
          ),
          new Expanded(
              child: new ListView(
                children: <Widget>[
                  new Container(
                    padding: EdgeInsets.all(20.0),
                    child: new Text(
                      "In order to use photoview in a box with the size different than the screen, use the class PhotoViewInline",
                      style: const TextStyle(
                          fontSize: 18.0
                      ),
                    ),
                  ),
                  new Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 20.0
                    ),
                    height: 300.0,
                    child: new PhotoViewInline(
                      imageProvider: AssetImage("assets/large-image.jpg"),
                      maxScale: PhotoViewScaleBoundary.covered,
                    ),
                  ),
                ],
              )
          )
        ],
      ),
    );
  }
}
