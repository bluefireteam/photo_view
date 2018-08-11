import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

void main() => runApp(new MyApp());


ThemeData theme =  new ThemeData(
    primaryColor: Colors.black,
    backgroundColor: Colors.white10
);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Photo View example',
      theme: theme,
      home: new Scaffold(
        body: new Home(),
      ),
    );
  }
}

var imageLarge = "https://images.unsplash.com/photo-1495249737766-5aa052764eff?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=7d968dee23958e5a65a99699c1a4ba05&auto=format&fit=crop&w=1500&q=80";
var imageSmall = "https://images.unsplash.com/photo-1522891735718-6a86a483c165?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=300&h=200&fit=crop&ixid=eyJhcHBfaWQiOjF9&s=99553e144acd1557b378071c47042188";
var imageGif = "https://78.media.tumblr.com/db333e9e3de2cab4498263948e37c789/tumblr_pcr1okpIr01svh4goo1_500.gif";


class Home extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Expanded(child:  new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              buildOption(
                context,
                text: "open small image",
                imageUrl: imageSmall,
                minScale: 0.1,
                maxScale: 1.05
              ),
              buildOption(
                  context,
                  text: "open large image",
                  imageUrl: imageLarge,
                  minScale: PhotoViewScaleBoundary.contained,
                  maxScale: PhotoViewScaleBoundary.covered
              ),
              buildOption(
                  context,
                  text: "open gif",
                  imageUrl: imageGif,
              ),
            ],
          ))


        ],
      ),
    );
  }


  Widget buildOption(BuildContext context, {
    String text,
    String imageUrl,
    minScale,
    maxScale
  }) {
    return new Center(
      child: new RaisedButton(
        onPressed: () {
          Navigator.push(
            context,
            new MaterialPageRoute(builder: (context) => new ImageViewScreen(
              imageUrl,
              minScale: minScale,
              maxScale: maxScale,
            )),
          );
        },
        color: Colors.green,
        child: new Text(text,
          style: new TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
          ),)
      )
    );
  }
}



class ImageViewScreen extends StatelessWidget {
  final String imageAddress;

  var maxScale;
  var minScale;

  ImageViewScreen(this.imageAddress,{
    @required this.minScale,
    @required this.maxScale
  });

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("hello"),
      ),
      body: new Container(
        child: new ConstrainedBox(
          constraints: new BoxConstraints.expand(),
          child: new PhotoViewInline(
            imageProvider: new NetworkImage(imageAddress),
            loadingChild: new LoadingText(),
            backgroundColor: Colors.black,
            minScale: minScale,
            maxScale: maxScale,
          ),
        )
      ),
    );
  }

}

class LoadingText extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new Text("Loading",
      style: new TextStyle(
          color: Colors.white
      ),
    );
  }
}
