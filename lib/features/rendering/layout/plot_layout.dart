import 'package:flutter/material.dart';

class PlotLayout {
  final double paddingLeft;
  final double paddingBottom;
  final double paddingTop;
  final double paddingRight;

  const PlotLayout({
    this.paddingLeft = 28,
    this.paddingBottom = 24,
    this.paddingTop = 8,
    this.paddingRight = 8,
  });

  Rect plotRect(Size size) {
    return Rect.fromLTWH(
      paddingLeft,
      paddingTop,
      size.width - paddingLeft - paddingRight,
      size.height - paddingTop - paddingBottom,
    );
  }

  Rect xAxisRect(Size size) {
    final plot = plotRect(size);
    return Rect.fromLTWH(
      plot.left,
      plot.bottom,
      plot.width,
      size.height - plot.bottom,
    );
  }

  Rect yAxisRect(Size size) {
    final plot = plotRect(size);
    return Rect.fromLTWH(
      0,
      plot.top,
      plot.left,
      plot.height,
    );
  }
}

