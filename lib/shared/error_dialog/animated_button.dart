import 'package:flutter/material.dart';

class AnimButton extends StatefulWidget {
  const AnimButton({
    super.key,
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final void Function() onTap;

  @override
  AnimButtonState createState() => AnimButtonState();
}

class AnimButtonState extends State<AnimButton> with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 100,
      ),
      lowerBound: 0.0,
      upperBound: 0.15,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      onTapUp: (details) {
        _controller.reverse();
      },
      onTapDown: (details) {
        _controller.forward();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: Transform.scale(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}

class CustomButtonStyle extends StatelessWidget {
  const CustomButtonStyle({
    super.key,
    this.child,
    this.color,
    this.padding,
    this.border,
  });

  final Widget? child;
  final Color? color;
  final EdgeInsets? padding;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).primaryColorLight,
        borderRadius: BorderRadius.circular(10),
        border: border,
      ),
      child: child,
    );
  }
}
