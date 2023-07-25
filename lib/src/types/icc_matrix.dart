import 'dart:collection';

import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:icc_parser/src/utils/num_utils.dart';
import 'package:meta/meta.dart';

@immutable
final class IccMatrix {
  final List<double> matrix;

  const IccMatrix(this.matrix) : assert(matrix.length == 12);

  factory IccMatrix.fromBytes(DataStream stream) {
    final matrix = List.generate(
      12,
      (_) => stream.readSigned15Fixed16Number().value,
    );
    return IccMatrix(UnmodifiableListView(matrix));
  }

  bool isIdentity() {
    if (matrix[9].abs() > 0 || matrix[10].abs() > 0 || matrix[11].abs() > 0) {
      return false;
    }
    if (!isUnity(matrix[0]) || !isUnity(matrix[4]) || !isUnity(matrix[8])) {
      return false;
    }

    if (matrix[1].abs() > 0 ||
        matrix[2].abs() > 0 ||
        matrix[3].abs() > 0 ||
        matrix[5].abs() > 0 ||
        matrix[6].abs() > 0 ||
        matrix[7].abs() > 0) {
      return false;
    }
    return true;
  }

  void apply(List<double> pixel) {
    final a = pixel[0];
    final b = pixel[1];
    final c = pixel[2];

    pixel[0] = a * matrix[0] + b * matrix[1] + c * matrix[2] + matrix[9];
    pixel[1] = a * matrix[3] + b * matrix[4] + c * matrix[5] + matrix[10];
    pixel[2] = a * matrix[6] + b * matrix[7] + c * matrix[8] + matrix[11];
  }
}
