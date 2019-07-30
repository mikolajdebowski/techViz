import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration period;
  final Gradient gradient;
  final String direction;

  const Shimmer({Key key, this.child, this.period, this.gradient, this.direction}): super(key: key);

  Shimmer.fromColors(
      {Key key,
        @required this.child,
        @required Color baseColor,
        @required Color highlightColor,
        @required this.direction,
        this.period = const Duration(milliseconds: 1500)})
      : gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.centerRight,
      colors: [
        baseColor,
        baseColor,
        highlightColor,
        baseColor,
        baseColor
      ],
      stops: const [
        0.0,
        0.35,
        0.5,
        0.65,
        1.0
      ]),
        super(key: key);

  @override
  _ShimmerState createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with TickerProviderStateMixin {

  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: widget.period)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.repeat();
        }
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: widget.child,
      direction: widget.direction,
      gradient: widget.gradient,
      percent: controller.value,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}


class _Shimmer extends SingleChildRenderObjectWidget {
  final Gradient gradient;
  final double percent;
  final String direction;

  const _Shimmer({Widget child, this.gradient, this.percent, this.direction})
      : super(child: child);

  @override
  _ShimmerFilter createRenderObject(BuildContext context) {
    return _ShimmerFilter(percent, gradient, direction);
  }

  @override
  void updateRenderObject(BuildContext context, _ShimmerFilter shimmer) {
    shimmer.percent = percent;
  }
}


class _ShimmerFilter extends RenderProxyBox {
  final _clearPaint = Paint();
  final Paint _gradientPaint;
  final Gradient _gradient;
  double _percent;

  final String _direction;

  _ShimmerFilter(this._percent, this._gradient, this._direction)
      : _gradientPaint = Paint()..blendMode = BlendMode.srcIn;

  @override
  bool get alwaysNeedsCompositing => child != null;

  set percent(double newValue) {
    if (newValue != _percent) {
      _percent = newValue;
      markNeedsPaint();
    }
  }


  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      assert(needsCompositing);

      final width = child.size.width;
      final height = child.size.height;
      Rect rect;
      double dx, dy;

      if (_direction == 'rtl') {
        dx = _offset(width, -width, _percent);
        dy = 0.0;
        rect = Rect.fromLTWH(offset.dx - width, offset.dy, 3 * width, height);
      } else if (_direction == 'ltr'){
        dx = _offset(-width, width, _percent);
        dy = 0.0;
        rect = Rect.fromLTWH(offset.dx - width, offset.dy, 3 * width, height);
      }

      _gradientPaint.shader = _gradient.createShader(rect);

      context.canvas.saveLayer(offset & child.size, _clearPaint);
      context.paintChild(child, offset);
      context.canvas.translate(dx, dy);
      context.canvas.drawRect(rect, _gradientPaint);
      context.canvas.restore();
    }
  }

  double _offset(double start, double end, double percent) {
    return start + (end - start) * percent;
  }
}