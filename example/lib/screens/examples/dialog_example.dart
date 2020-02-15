import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view_example/screens/app_bar.dart';

class DialogExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DialogExampleInner(),
    );
  }
}

class DialogExampleInner extends StatefulWidget {
  @override
  _DialogExampleInnerState createState() => _DialogExampleInnerState();
}

class _DialogExampleInnerState extends State<DialogExampleInner> {
  VoidCallback openDialog(BuildContext context) => () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                child: PhotoView(
                  tightMode: true,
                  imageProvider: const AssetImage("assets/large-image.jpg"),
                  heroAttributes: const PhotoViewHeroAttributes(tag: "someTag"),
                ),
              ),
            );
          },
        );
      };

  VoidCallback openBottomSheet(BuildContext context) => () {
        showBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          shape: const ContinuousRectangleBorder(),
          builder: (BuildContext context) {
            return PhotoViewGestureDetectorScope(
              axis: Axis.vertical,
              child: PhotoView(
                backgroundDecoration:
                    BoxDecoration(color: Colors.black.withAlpha(240)),
                imageProvider: const AssetImage("assets/large-image.jpg"),
                heroAttributes: const PhotoViewHeroAttributes(tag: "someTag"),
              ),
            );
          },
        );
      };

  VoidCallback openBottomSheetModal(BuildContext context) => () {
        showModalBottomSheet(
          context: context,
          shape: const ContinuousRectangleBorder(),
          builder: (BuildContext context) {
            return SafeArea(
              child: Container(
                height: 250,
                child: PhotoViewGestureDetectorScope(
                  axis: Axis.vertical,
                  child: PhotoView(
                    tightMode: true,
                    imageProvider: const AssetImage("assets/large-image.jpg"),
                    heroAttributes:
                        const PhotoViewHeroAttributes(tag: "someTag"),
                  ),
                ),
              ),
            );
          },
        );
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const ExampleAppBar(
          title: "Dialog Example",
          showGoBack: true,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(color: Colors.red),
              ),
              RaisedButton(
                child: const Text("Dialog"),
                onPressed: openDialog(context),
              ),
              const Divider(),
              RaisedButton(
                child: const Text("Bottom sheet"),
                onPressed: openBottomSheet(context),
              ),
              const Divider(),
              RaisedButton(
                child: const Text("Bottom sheet tight mode"),
                onPressed: openBottomSheetModal(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
