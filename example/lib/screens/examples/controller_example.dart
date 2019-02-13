import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view_example/screens/app_bar.dart';

class ControllerExample extends StatefulWidget {
  @override
  _ControllerExampleState createState() => _ControllerExampleState();
}

double min = pi * -2;
double max = pi * 2;

class _ControllerExampleState extends State<ControllerExample> {
  PhotoViewController controller;

  @override
  void initState() {
    controller = PhotoViewController();
    // TODO: implement initState
    super.initState();
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
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          height: 120,
                          left: 0,
                          right: 0,
                          child: Container(
                              padding: const EdgeInsets.all(30.0),
                              child: StreamBuilder(
                                  stream: controller.outputStateStream,
                                  initialData: controller.value,
                                  builder: (BuildContext context,
                                      AsyncSnapshot snapshot) {
                                    if (snapshot.hasError ||
                                        !snapshot.hasData) {
                                      return Container();
                                    }
                                    final PhotoViewControllerValue value =
                                        snapshot.data;
                                    return Column(
                                      children: <Widget>[
                                        Text("Rotation ${value.rotation}",
                                          style: TextStyle(
                                              color: Colors.white
                                          ),
                                        ),
                                        SliderTheme(
                                            data: SliderTheme.of(context)
                                                .copyWith(
                                                    activeTrackColor:
                                                        Colors.orange,
                                                    thumbColor: Colors.orange),
                                            child: Slider(
                                                value: value.rotation
                                                    .clamp(min, max),
                                                min: min,
                                                max: max,
                                                onChanged:
                                                    (double newRotation) {
                                                  controller.rotation =
                                                      newRotation;
                                                  controller.scaleState =
                                                      PhotoViewScaleState
                                                          .zooming;
                                                })),

                                      ],
                                    );
                                  })),
                        )
                      ],
                    ),
                  )),
            ],
          )),
    );
  }
}
