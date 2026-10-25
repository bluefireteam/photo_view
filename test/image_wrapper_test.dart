import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_view/photo_view.dart';

class _TestImageStreamCompleter extends ImageStreamCompleter {
  void frame(ImageInfo info) => setImage(info);

  void chunk(ImageChunkEvent event) => reportImageChunkEvent(event);

  void fail(Object error) => reportError(exception: error);
}

class _TestImageProvider extends ImageProvider<Object> {
  _TestImageProvider(this.completer, {this.key});

  final _TestImageStreamCompleter completer;
  final Object? key;

  @override
  Future<Object> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<Object>(key ?? this);
  }

  @override
  ImageStreamCompleter loadImage(Object key, ImageDecoderCallback decode) {
    return completer;
  }
}

Widget _photoView(ImageProvider imageProvider, {bool gaplessPlayback = false}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: PhotoView(
      imageProvider: imageProvider,
      gaplessPlayback: gaplessPlayback,
      loadingBuilder: (_, __) => const Text('loading'),
      errorBuilder: (_, __, ___) => const Text('error'),
    ),
  );
}

void main() {
  late ui.Image image;

  setUp(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    image = (await binding.runAsync(
      () => createTestImage(width: 10, height: 10),
    ))!;
  });

  tearDown(() {
    imageCache.clear();
  });

  testWidgets('switching provider after an error does not crash',
      (tester) async {
    final first = _TestImageStreamCompleter();
    final second = _TestImageStreamCompleter();

    await tester.pumpWidget(_photoView(_TestImageProvider(first)));
    first.fail(Exception('failed to load'));
    await tester.pump();
    expect(find.text('error'), findsOneWidget);

    await tester.pumpWidget(_photoView(_TestImageProvider(second)));
    second.chunk(const ImageChunkEvent(
      cumulativeBytesLoaded: 1,
      expectedTotalBytes: 2,
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('loading'), findsOneWidget);

    second.frame(ImageInfo(image: image.clone()));
    await tester.pump();
    expect(find.text('loading'), findsNothing);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('shows the loading builder when the provider changes',
      (tester) async {
    final first = _TestImageStreamCompleter();
    final second = _TestImageStreamCompleter();

    await tester.pumpWidget(_photoView(_TestImageProvider(first)));
    first.frame(ImageInfo(image: image.clone()));
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);

    await tester.pumpWidget(_photoView(_TestImageProvider(second)));
    expect(find.text('loading'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('keeps the previous image when gaplessPlayback is true',
      (tester) async {
    final first = _TestImageStreamCompleter();
    final second = _TestImageStreamCompleter();

    await tester.pumpWidget(
      _photoView(_TestImageProvider(first), gaplessPlayback: true),
    );
    first.frame(ImageInfo(image: image.clone()));
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);

    await tester.pumpWidget(
      _photoView(_TestImageProvider(second), gaplessPlayback: true),
    );
    expect(find.text('loading'), findsNothing);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('a new provider resolving to the same image stays loaded',
      (tester) async {
    final completer = _TestImageStreamCompleter();
    final key = Object();

    await tester.pumpWidget(
      _photoView(_TestImageProvider(completer, key: key)),
    );
    completer.frame(ImageInfo(image: image.clone()));
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);

    await tester.pumpWidget(
      _photoView(_TestImageProvider(completer, key: key)),
    );
    await tester.pump();
    expect(find.text('loading'), findsNothing);
    expect(find.byType(Image), findsOneWidget);
  });
}
