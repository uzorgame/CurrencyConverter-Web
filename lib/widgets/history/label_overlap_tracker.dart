import 'package:flutter/material.dart';

class LabelOverlapTracker {
  LabelOverlapTracker(this.minSpacing);

  final double minSpacing;
  Rect? _lastBounds;

  bool isOverlapping(Rect nextBounds) {
    if (_lastBounds == null) {
      _lastBounds = nextBounds;
      return false;
    }

    final last = _lastBounds!.inflate(minSpacing / 2);
    final current = nextBounds.inflate(minSpacing / 2);
    final overlaps = last.overlaps(current);
    if (!overlaps) {
      _lastBounds = nextBounds;
    }
    return overlaps;
  }
}


