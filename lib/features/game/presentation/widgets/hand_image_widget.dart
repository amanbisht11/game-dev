import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HandImageWidget extends StatelessWidget {
  final int number;
  final double size;
  final bool mirror;

  const HandImageWidget({
    super.key,
    required this.number,
    this.size = 100,
    this.mirror = false,
  });

  @override
  Widget build(BuildContext context) {
    if (number < 1 || number > 6) return const SizedBox.shrink();

    Widget image = Image.asset(
      'assets/images/hand_$number.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.back_hand,
        size: size,
        color: Colors.white,
      ),
    );

    if (mirror) {
      image = Transform.scale(
        scaleX: -1,
        child: image,
      );
    }

    return image.animate().scale(
      duration: 300.ms,
      curve: Curves.easeOutBack,
    ).shake(
      delay: 300.ms,
      duration: 200.ms,
      hz: 3,
      curve: Curves.easeInOut,
    );
  }
}
