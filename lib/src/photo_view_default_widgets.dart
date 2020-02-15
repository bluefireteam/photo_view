import 'package:flutter/material.dart';

class PhotoViewDefaultError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.broken_image,
        color: Colors.grey[400],
        size: 40.0,
      ),
    );
  }
}

class PhotoViewDefaultLoading extends StatelessWidget {
  const PhotoViewDefaultLoading({Key key, this.event}) : super(key: key);

  final ImageChunkEvent event;

  @override
  Widget build(BuildContext context) {
    final value = event == null
        ? 0.0
        : event.cumulativeBytesLoaded / event.expectedTotalBytes;
    return Center(
      child: Container(
        width: 20.0,
        height: 20.0,
        child: CircularProgressIndicator(value: value),
      ),
    );
  }
}
