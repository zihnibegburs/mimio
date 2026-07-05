import 'package:flutter/material.dart';

/// Brand mark used on auth and onboarding screens.
class MimioLogo extends StatelessWidget {
  const MimioLogo({super.key, this.size = 80});

  final double size;

  @override
  Widget build(BuildContext context) {
    final px = (size * MediaQuery.devicePixelRatioOf(context)).round();
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        'assets/icons/app_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        cacheWidth: px,
        cacheHeight: px,
        gaplessPlayback: true,
      ),
    );
  }
}
