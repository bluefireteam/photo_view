import 'package:flutter/widgets.dart';

class GalleryExampleItem {

  GalleryExampleItem({this.id, this.image});

  String id;
  String image;

}


class GalleryExampleItemThumbnail extends StatelessWidget {

  const GalleryExampleItemThumbnail({Key key, this.galleryExampleItem, this.onTap}) : super(key: key);

  final GalleryExampleItem galleryExampleItem;

  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: GestureDetector(
          onTap: onTap,
          child: Hero(
            tag: galleryExampleItem.id,
            child: Image.asset(galleryExampleItem.image, height: 80.0),
          ),
        ));
  }

}


List<GalleryExampleItem> galleryItems = <GalleryExampleItem>[
  GalleryExampleItem(
    id: "tag1",
    image: "assets/gallery1.jpeg",
  ),
  GalleryExampleItem(
    id: "tag2",
    image: "assets/gallery2.jpeg",
  ),
  GalleryExampleItem(
    id: "tag3",
    image: "assets/gallery3.jpeg",
  ),
];