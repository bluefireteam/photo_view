
class PhotoViewScaleBoundary {
  final String _value;
  final double multiplier;
  const PhotoViewScaleBoundary._internal(this._value, [this.multiplier = 1.0]);

  @override
  String toString() => 'Enum.$_value';

  static const contained = const PhotoViewScaleBoundary._internal('contained');
  static const covered = const PhotoViewScaleBoundary._internal('covered');

  PhotoViewScaleBoundary operator * (double multiplier){
    return new PhotoViewScaleBoundary._internal(_value, multiplier);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PhotoViewScaleBoundary &&
              runtimeType == other.runtimeType &&
              _value == other._value;

  @override
  int get hashCode => _value.hashCode;



}