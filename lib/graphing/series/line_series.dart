import 'package:flutter/material.dart';
import 'package:libra_sheet/graphing/cartesian/cartesian_coordinate_space.dart';
import 'package:libra_sheet/graphing/series/series.dart';

class LineSeriesPoint<T> {
  final int index;
  final T item;
  final Offset value;
  final Offset pixelPos;

  LineSeriesPoint({
    required this.index,
    required this.item,
    required this.value,
    required this.pixelPos,
  });
}

class LineSeries<T> extends Series<T> {
  final Color color;
  final Offset Function(int i, T item) valueMapper;
  final Paint _painter;

  /// Cache the points to enable easy hit testing
  final List<LineSeriesPoint<T>> _renderedPoints = [];

  LineSeries({
    required super.name,
    required super.data,
    required this.valueMapper,
    this.color = Colors.blue,
  }) : _painter = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

  LineSeriesPoint<T> _addPoint(CartesianCoordinateSpace coordSpace, int i) {
    final item = data[i];
    final value = valueMapper(i, item);
    final pixelPos = coordSpace.userToPixel(value);
    final out = LineSeriesPoint(index: i, item: item, value: value, pixelPos: pixelPos);
    _renderedPoints.add(out);
    return out;
  }

  @override
  void paint(Canvas canvas, CartesianCoordinateSpace coordSpace) {
    _renderedPoints.clear();
    if (data.length <= 1) return;

    final path = Path();
    final start = _addPoint(coordSpace, 0);
    path.moveTo(start.pixelPos.dx, start.pixelPos.dy);
    for (int i = 1; i < data.length; i++) {
      final curr = _addPoint(coordSpace, i);
      path.lineTo(curr.pixelPos.dx, curr.pixelPos.dy);
    }

    canvas.drawPath(path, _painter);
  }

  @override
  BoundingBox boundingBox(int i) {
    return BoundingBox.fromPoint(valueMapper(i, data[i]));
  }
}

final testSeries = LineSeries(
  name: 'test',
  data: [10000.0, 20000.0, 15000.0, -8000.0, -9000.0, 7000.0],
  valueMapper: (i, it) => Offset(i.toDouble(), it),
);
