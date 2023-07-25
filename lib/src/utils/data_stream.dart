import 'dart:typed_data';

import 'package:icc_parser/src/types/primitive.dart';

class DataStream {
  final ByteData _data;
  final int _length;
  final int _offset;
  int _position = 0;

  int get position => _position;

  DataStream({
    required final ByteData data,
    required final int length,
    required final int offset,
  })  : _data = data,
        _length = length,
        _offset = offset;

  void seek(final int position) {
    assert(position >= 0, 'Position must be greater than or equal to 0');
    assert(position < _length, 'Position must be less than $_length');
    _position = position;
  }

  Unsigned32Number readUnsigned32Number() {
    final value =
        Unsigned32Number.fromBytes(_data, offset: _offset + _position);
    _position += 4;
    return value;
  }

  Unsigned16Number readUnsigned16Number() {
    final value =
        Unsigned16Number.fromBytes(_data, offset: _offset + _position);
    _position += 2;
    return value;
  }

  Unsigned8Number readUnsigned8Number() {
    final value = Unsigned8Number.fromBytes(_data, offset: _offset + _position);
    _position += 1;
    return value;
  }

  Signed15Fixed16Number readSigned15Fixed16Number() {
    final value =
        Signed15Fixed16Number.fromBytes(_data, offset: _offset + _position);
    _position += 4;
    return value;
  }

  void skip(final int numberOfBytes) {
    seek(position + numberOfBytes);
  }

  /// Operation to make sure read position is evenly divisible by 4
  void sync32(final int offset) {
    final updatedOffset = offset & 0x3;
    final pos = ((position - updatedOffset + 3) >> 2) << 2;
    seek(pos + updatedOffset);
  }
}