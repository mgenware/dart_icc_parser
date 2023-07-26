import 'package:icc_parser/src/cmm/icc_transform.dart';
import 'package:icc_parser/src/icc_parser_base.dart';
import 'package:icc_parser/src/types/icc_matrix.dart';
import 'package:icc_parser/src/types/tag/curve/icc_curve.dart';
import 'package:icc_parser/src/types/tag/lut/icc_mbb.dart';
import 'package:meta/meta.dart';

@immutable
final class IccTransform4DLut extends IccTransform {
  final IccMBB tag;
  final List<IccCurve>? aCurves;
  final List<IccCurve>? bCurves;
  final List<IccCurve>? mCurves;
  final IccMatrix? matrix;

  const IccTransform4DLut({
    required this.aCurves,
    required this.bCurves,
    required this.mCurves,
    required this.matrix,
    required this.tag,
    required super.profile,
    required super.doAdjustPCS,
    required super.isInput,
    required super.srcPCSConversion,
    required super.pcsScale,
    required super.pcsOffset,
    required super.dstPCSConversion,
  });

  factory IccTransform4DLut.fromTag({
    required IccMBB tag,
    required IccProfile profile,
    required bool doAdjustPCS,
    required bool isInput,
    required bool srcPCSConversion,
    required bool dstPCSConversion,
    required List<double>? pcsScale,
    required List<double>? pcsOffset,
  }) {
    final params = _begin(tag);
    return IccTransform4DLut(
      aCurves: params.aCurves,
      bCurves: params.bCurves,
      mCurves: params.mCurves,
      matrix: params.matrix,
      tag: tag,
      profile: profile,
      doAdjustPCS: doAdjustPCS,
      isInput: isInput,
      srcPCSConversion: srcPCSConversion,
      pcsScale: pcsScale,
      pcsOffset: pcsOffset,
      dstPCSConversion: dstPCSConversion,
    );
  }

  @override
  List<double> apply(List<double> source) {
    final sourcePixel = checkSourceAbsolute(source);
    final pixel = [...sourcePixel];
    if (tag.isInputMatrix) {
      if (bCurves != null) {
        pixel[0] = bCurves![0].apply(pixel[0]);
        pixel[1] = bCurves![1].apply(pixel[1]);
        pixel[2] = bCurves![2].apply(pixel[2]);
        pixel[3] = bCurves![3].apply(pixel[3]);
      }
      if (tag.clut != null) {
        final res = tag.clut!.interpolate4d(pixel);
        pixel[0] = res[0];
        pixel[1] = res[1];
        pixel[2] = res[2];
      }
      if (aCurves != null) {
        for (var i = 0; i < tag.outputChannelCount; i++) {
          pixel[i] = aCurves![i].apply(pixel[i]);
        }
      }
    } else {
      if (aCurves != null) {
        pixel[0] = aCurves![0].apply(pixel[0]);
        pixel[1] = aCurves![1].apply(pixel[1]);
        pixel[2] = aCurves![2].apply(pixel[2]);
        pixel[3] = aCurves![3].apply(pixel[3]);
      }
      if (tag.clut != null) {
        final res = tag.clut!.interpolate4d(pixel);
        pixel[0] = res[0];
        pixel[1] = res[1];
        pixel[2] = res[2];
        pixel[3] = res[3];
      }
      if (mCurves != null) {
        for (var i = 0; i < tag.outputChannelCount; i++) {
          pixel[i] = mCurves![i].apply(pixel[i]);
        }
      }
      if (matrix != null) {
        matrix!.apply(pixel);
      }
      if (bCurves != null) {
        for (var i = 0; i < tag.outputChannelCount; i++) {
          pixel[i] = bCurves![i].apply(pixel[i]);
        }
      }
    }

    return checkDestinationAbsolute(pixel).sublist(0, tag.outputChannelCount);
  }

  @override
  bool get useLegacyPCS => tag.useLegacyPCS;

  static ({
    List<IccCurve>? aCurves,
    List<IccCurve>? bCurves,
    List<IccCurve>? mCurves,
    IccMatrix? matrix,
  }) _begin(IccMBB tag) {
    assert(tag.inputChannelCount == 4);

    List<IccCurve>? usedACurves;
    List<IccCurve>? usedBCurves;
    List<IccCurve>? usedMCurves;
    final aCurves = tag.aCurves;
    final bCurves = tag.bCurves;
    final mCurves = tag.mCurves;
    if (tag.isInputMatrix) {
      if (bCurves != null) {
        for (final curve in bCurves) {
          if (!curve.isIdentity) {
            usedBCurves = bCurves;
            break;
          }
        }
      }
      if (aCurves != null) {
        for (final curve in aCurves) {
          if (!curve.isIdentity) {
            usedACurves = aCurves;
            break;
          }
        }
      }
    } else {
      // !isInputMatrix
      if (aCurves != null) {
        for (final curve in aCurves) {
          if (!curve.isIdentity) {
            usedACurves = aCurves;
            break;
          }
        }
      }
      if (bCurves != null) {
        for (final curve in bCurves) {
          if (!curve.isIdentity) {
            usedBCurves = bCurves;
            break;
          }
        }
      }
      if (mCurves != null) {
        for (final curve in mCurves) {
          if (!curve.isIdentity) {
            usedMCurves = mCurves;
            break;
          }
        }
      }
    }

    IccMatrix? usedMatrix;
    final matrix = tag.matrix;
    if (matrix != null) {
      if (!matrix.isIdentity()) {
        usedMatrix = matrix;
      }
    }

    return (
      mCurves: usedMCurves,
      aCurves: usedACurves,
      bCurves: usedBCurves,
      matrix: usedMatrix,
    );
  }
}
