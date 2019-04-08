import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view_example/screens/app_bar.dart';

class ControllerExample extends StatefulWidget {
  @override
  _ControllerExampleState createState() => _ControllerExampleState();
}

const double min = pi * -2;
const double max = pi * 2;

const double minScale = 0.05;
const double defScale = 0.1;
const double maxScale = 0.2;

class _ControllerExampleState extends State<ControllerExample> {
  PhotoViewControllerBase controller;

  int calls = 0;

  @override
  void initState() {
    controller = PhotoViewController();
    controller
      ..scale = defScale
      ..scaleState = PhotoViewScaleState.zooming
      ..outputStateStream.listen(onControllerState);
    // TODO: implement initState

    super.initState();
  }

  void onControllerState(PhotoViewControllerValue value) {
    setState(() {
      calls += 1;
      print("Update stream ${value.scaleState}");
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const ExampleAppBar(
                title: "Controller Examples",
                showGoBack: true,
              ),
              Flexible(
                  flex: 1,
                  child: ClipRect(
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: PhotoView(
                            imageProvider:
                                const AssetImage("assets/large-image.jpg"),
                            controller: controller,
                            enableRotation: true,
                            initialScale: defScale,
                            minScale: minScale,
                            maxScale: maxScale,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          height: 180,
                          left: 0,
                          right: 0,
                          child: Container(
                              padding: const EdgeInsets.all(30.0),
                              child: StreamBuilder(
                                  stream: controller.outputStateStream,
                                  initialData: controller.value,
                                  builder: _streamBuild)),
                        )
                      ],
                    ),
                  )),
            ],
          )),
    );
  }

  Widget _streamBuild(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasError || !snapshot.hasData) {
      return Container();
    }
    final PhotoViewControllerValue value = snapshot.data;
    return Column(
      children: <Widget>[
        Text(
          "Rotation ${value.rotation}",
          style: TextStyle(color: Colors.white),
        ),
        SliderTheme(
            data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.orange, thumbColor: Colors.orange),
            child: Slider(
                value: value.rotation.clamp(min, max),
                min: min,
                max: max,
                onChanged: (double newRotation) {
                  controller.rotation = newRotation;
                  controller.scaleState = PhotoViewScaleState.zooming;
                })),
        Text(
          "Scale ${value.scale}",
          style: TextStyle(color: Colors.white),
        ),
        SliderTheme(
            data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.orange, thumbColor: Colors.orange),
            child: Slider(
                value: value.scale.clamp(minScale, maxScale),
                min: minScale,
                max: maxScale,
                onChanged: (double newScale) {
                  controller.scale = newScale;
                  controller.scaleState = PhotoViewScaleState.zooming;
                })),
      ],
    );
  }
}
