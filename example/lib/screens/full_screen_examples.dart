import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import './app_bar.dart';

class FullScreenExamples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const ExampleAppBar(
            title: "Full Screen Examples",
            showGoBack: true,
          ),
          new Expanded(
              child: new ListView(
            children: <Widget>[
              new ExampleButtonNode(
                  title: "Large Image",
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FullScreenWrapper(
                                imageProvider:
                                    const AssetImage("assets/large-image.jpg"),
                              ),
                        ));
                  }),
              new ExampleButtonNode(
                  title: "Small Image (custom background)",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FullScreenWrapper(
                              imageProvider:
                                  const AssetImage("assets/small-image.jpg"),
                              backgroundColor: Colors.pinkAccent,
                            ),
                      ),
                    );
                  }),
              new ExampleButtonNode(
                  title: "Image from the internet",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FullScreenWrapper(
                              imageProvider: const NetworkImage(
                                  "https://source.unsplash.com/900x1600/?camera,paper"),
                            ),
                      ),
                    );
                  }),
              new ExampleButtonNode(
                  title: "Animated GIF",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FullScreenWrapper(
                              imageProvider:
                                  const AssetImage("assets/peanut.gif"),
                              backgroundColor: Colors.white,
                              maxScale: 2.0,
                            ),
                      ),
                    );
                  }),

              /* TODO: https://github.com/renancaraujo/photo_view/issues/12
                new ExampleButtonNode(
                  title: "Image in memory",
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenWrapper(),
                      ),
                    );
                  }
                ),
*/

              new ExampleButtonNode(
                  title: "Limited scale",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenWrapper(
                              imageProvider:
                                  const AssetImage("assets/large-image.jpg"),
                              minScale: PhotoViewComputedScale.contained * 0.8,
                              maxScale: PhotoViewComputedScale.covered * 1.1,
                            ),
                      ),
                    );
                  }),
            ],
          ))
        ],
      ),
    );
  }
}

class ExampleButtonNode extends StatelessWidget {
  final String title;
  final Function onPressed;

  const ExampleButtonNode({
    this.title,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
        margin: const EdgeInsets.symmetric(
          vertical: 20.0,
        ),
        child: new Column(
          children: <Widget>[
            new Text(
              title,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 21.0,
                  fontWeight: FontWeight.w600),
            ),
            new Container(
                margin: const EdgeInsets.only(
                  top: 10.0,
                ),
                child: new RaisedButton(
                  onPressed: onPressed,
                  child: const Text("Open example"),
                  color: Colors.amber,
                ))
          ],
        ));
  }
}

class FullScreenWrapper extends StatelessWidget {
  final ImageProvider imageProvider;
  final Widget loadingChild;
  final Color backgroundColor;
  final dynamic minScale;
  final dynamic maxScale;

  const FullScreenWrapper(
      {this.imageProvider,
      this.loadingChild,
      this.backgroundColor,
      this.minScale,
      this.maxScale});

  @override
  Widget build(BuildContext context) {
    return new Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: new PhotoView(
          imageProvider: imageProvider,
          loadingChild: loadingChild,
          backgroundColor: backgroundColor,
          minScale: minScale,
          maxScale: maxScale,
        ));
  }
}
