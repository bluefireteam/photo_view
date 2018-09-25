class PhotoViewComputedScale {
  final String _value;
  final double multiplier;
  const PhotoViewComputedScale._internal(this._value, [this.multiplier = 1.0]);

  @override
  String toString() => 'Enum.$_value';

  static const contained = const PhotoViewComputedScale._internal('contained');
  static const covered = const PhotoViewComputedScale._internal('covered');

  PhotoViewComputedScale operator *(double multiplier) {
    return PhotoViewComputedScale._internal(_value, multiplier);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoViewComputedScale &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}
