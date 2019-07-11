import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view_example/screens/app_bar.dart';

class FullScreenExamples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const ExampleAppBar(
            title: "Full Screen Examples",
            showGoBack: true,
          ),
          Expanded(
              child: ListView(
            children: <Widget>[
              ExampleButtonNode(
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
              ExampleButtonNode(
                  title: "Small Image (custom background)",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FullScreenWrapper(
                          imageProvider:
                              const AssetImage("assets/small-image.jpg"),
                          backgroundDecoration: BoxDecoration(
                              gradient: LinearGradient(
                            colors: <Color>[Colors.white, Colors.grey],
                            stops: [0.1, 1.0],
                          )),
                        ),
                      ),
                    );
                  }),
              ExampleButtonNode(
                  title: "Small Image (custom alignment)",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FullScreenWrapper(
                          imageProvider:
                              const AssetImage("assets/small-image.jpg"),
                          backgroundDecoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          basePosition: Alignment(0.5, 0.0),
                        ),
                      ),
                    );
                  }),
              ExampleButtonNode(
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
              ExampleButtonNode(
                  title: "Animated GIF",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FullScreenWrapper(
                          imageProvider: const AssetImage("assets/peanut.gif"),
                          //backgroundDecoration:
                          //   BoxDecoration(color: Colors.white),
                          //axScale: 2.0,
                        ),
                      ),
                    );
                  }),
              ExampleButtonNode(
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
                          initialScale: PhotoViewComputedScale.covered * 1.1,
                        ),
                      ),
                    );
                  }),
              ExampleButtonNode(
                  title: "Custom Initial scale",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenWrapper(
                          imageProvider:
                              const AssetImage("assets/large-image.jpg"),
                          initialScale: PhotoViewComputedScale.contained * 0.7,
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
  const ExampleButtonNode({
    this.title,
    this.onPressed,
  });

  final String title;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(
          vertical: 20.0,
        ),
        child: Column(
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 21.0,
                  fontWeight: FontWeight.w600),
            ),
            Container(
                margin: const EdgeInsets.only(
                  top: 10.0,
                ),
                child: RaisedButton(
                  onPressed: onPressed,
                  child: const Text("Open example"),
                  color: Colors.amber,
                ))
          ],
        ));
  }
}

class FullScreenWrapper extends StatelessWidget {
  const FullScreenWrapper(
      {this.imageProvider,
      this.loadingChild,
      this.backgroundDecoration,
      this.minScale,
      this.maxScale,
      this.initialScale,
      this.basePosition = Alignment.center});

  final ImageProvider imageProvider;
  final Widget loadingChild;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final dynamic initialScale;
  final Alignment basePosition;

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: PhotoView(
          imageProvider: imageProvider,
          loadingChild: loadingChild,
          backgroundDecoration: backgroundDecoration,
          minScale: minScale,
          maxScale: maxScale,
          initialScale: initialScale,
          basePosition: basePosition,
        ));
  }
}
