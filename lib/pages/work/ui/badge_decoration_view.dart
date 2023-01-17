import 'dart:math' as math;
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';

class BadgeDecoration extends Decoration {
  final Color badgeColor;
  final double badgeSize;
  final String text;
  final TextSpan textSpan;

  const BadgeDecoration(
      {@required this.badgeColor,
      this.badgeSize = 60.0,
      this.text,
      this.textSpan});

  @override
  BoxPainter createBoxPainter([onChanged]) =>
      _BadgePainter(badgeColor, badgeSize, text, textSpan);
}

class _BadgePainter extends BoxPainter {
  static const double BASELINE_SHIFT = 1;
  // ignore: unused_field
  static const double CORNER_RADIUS = 5;
  final Color badgeColor;
  final double badgeSize;
  final String text;
  final TextSpan textSpan;

  _BadgePainter(this.badgeColor, this.badgeSize, this.text, this.textSpan);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    canvas.save();
    canvas.translate(
        offset.dx + configuration.size.width - badgeSize, offset.dy);
    canvas.drawPath(buildBadgePath(), getBadgePaint());
    // draw text
    final hyp = math.sqrt(badgeSize * badgeSize + badgeSize * badgeSize);
    final textPainter = TextPainter(
        text: (textSpan ??
            TextSpan(
              text: text ?? '',
              style: TextStyles.textF12C2,
            )),
        maxLines: 1,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center);
    textPainter.layout(minWidth: hyp, maxWidth: hyp);
    final halfHeight = textPainter.size.height / 1.8;
    final v = math.sqrt(halfHeight * halfHeight + halfHeight * halfHeight) +
        BASELINE_SHIFT;
    canvas.translate(v, -v);
    canvas.rotate(0.65); // 45度: 0.785398
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  Paint getBadgePaint() => Paint()
    ..isAntiAlias = true
    ..color = badgeColor;

  Path buildBadgePath() => Path()
    ..moveTo(badgeSize - 25, 0)
    ..lineTo(badgeSize, 20)
    ..lineTo(badgeSize, badgeSize - 15)
    ..lineTo(0, 0)
    ..close();
}
