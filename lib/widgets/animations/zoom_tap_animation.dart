import 'package:flutter/cupertino.dart';

class ZoomTapAnimation extends StatefulWidget {
  final Widget child;
  final double begin, end;
  final Duration beginDuration, endDuration, longTapRepeatDuration;
  final Function()? onTap, onLongTap;

  // option to enable long tap loop which repeat every onTap event (in case onLongTap is specified, it repeats the onLongTap event).
  final bool enableLongTapRepeatEvent;

  final Curve beginCurve, endCurve;

  const ZoomTapAnimation(
      {super.key,
      required this.child,
      this.onTap,
      this.begin = 1.0,
      this.end = 0.93,
      this.beginDuration = const Duration(milliseconds: 20),
      this.endDuration = const Duration(milliseconds: 120),
      this.longTapRepeatDuration = const Duration(milliseconds: 100),
      this.beginCurve = Curves.decelerate,
      this.endCurve = Curves.fastOutSlowIn,
      this.onLongTap,
      this.enableLongTapRepeatEvent = false});

  @override
  State<StatefulWidget> createState() => _ZoomTapAnimationState();
}

class _ZoomTapAnimationState extends State<ZoomTapAnimation> with SingleTickerProviderStateMixin<ZoomTapAnimation> {
  // make AnimationController nullable to make sure to not use it if it's null
  AnimationController? _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // initial AnimationController
    _controller =
        AnimationController(vsync: this, duration: widget.endDuration, value: 1.0, reverseDuration: widget.beginDuration);
    // initial tween animation
    _animation = Tween(begin: widget.end, end: widget.begin)
        .animate(CurvedAnimation(parent: _controller!, curve: widget.beginCurve, reverseCurve: widget.endCurve));
    // animate the Tween animation from the begin point to the end point
    _controller?.forward();
  }

  bool _isOnTap = true;

  @override
  Widget build(BuildContext context) {
    Future<void> onLongPress() async {
      // animate the Tween animation from the begin point to the end point
      await _controller?.forward();
      // call long tap event
      await widget.onLongTap?.call();
    }

    return GestureDetector(
      onTap: widget.onTap,
      // call long tap one event if the long tap repeat(loop) is false
      onLongPress: widget.onLongTap != null && !widget.enableLongTapRepeatEvent ? onLongPress : null,
      child: Listener(
          onPointerDown: (c) async {
            // prevent the onTap event from beign triggered
            _isOnTap = true;
            // animate the Tween animation from the end point to the start point
            _controller?.reverse();
            // check if long tap loop is true
            if (widget.enableLongTapRepeatEvent) {
              // the duration before starting the loop event
              await Future.delayed(widget.longTapRepeatDuration);
              // _isOnTap is to check that the tap is still down (check onPointerUp method which assign _isOnTap to false)
              while (_isOnTap) {
                await Future.delayed(widget.longTapRepeatDuration, () async {
                  // call onTap if onLongTap is not specified
                  await (widget.onLongTap ?? widget.onTap)?.call();
                });
              }
            }
          },
          onPointerUp: (c) async {
            // prevent the onTap event from being triggered if the user has taped the widget for more than than 150 milliseconds
            _isOnTap = false;
            // animate the Tween animation from the begin point to the end point
            await _controller?.forward();
          },
          child: ScaleTransition(scale: _animation, child: widget.child)),
    );
  }

  @override
  void dispose() {
    // stop the running animation in the state
    _controller?.stop();
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }
}
