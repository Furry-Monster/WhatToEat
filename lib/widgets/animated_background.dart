import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:witch_one/theme/colors.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final List<Color> _glowColors = [
    AppColors.glowPurple.withOpacity(0.4),
    AppColors.glowBlue.withOpacity(0.4),
    AppColors.primary.withOpacity(0.4),
    AppColors.secondary.withOpacity(0.4),
    AppColors.tertiary.withOpacity(0.4),
  ];

  List<Map<String, dynamic>> _particles = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _initParticles();
  }

  void _initParticles() {
    for (int i = 0; i < 50; i++) {
      _particles.add({
        'x': _random.nextDouble() * 2 - 1,
        'y': _random.nextDouble() * 2 - 1,
        'size': _random.nextDouble() * 3 + 1,
        'speed': _random.nextDouble() * 0.3 + 0.1,
        'angle': _random.nextDouble() * math.pi * 2,
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Stack(
        children: [
          // 粒子效果
          ...List.generate(_particles.length, (index) {
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final particle = _particles[index];
                final value = _animationController.value;

                final x = particle['x'] +
                    math.cos(particle['angle']) * particle['speed'] * value;
                final y = particle['y'] +
                    math.sin(particle['angle']) * particle['speed'] * value;

                if (x.abs() > 1 || y.abs() > 1) {
                  particle['x'] = _random.nextDouble() * 2 - 1;
                  particle['y'] = _random.nextDouble() * 2 - 1;
                  particle['angle'] = _random.nextDouble() * math.pi * 2;
                }

                return Positioned(
                  left: (x + 1) * MediaQuery.of(context).size.width / 2,
                  top: (y + 1) * MediaQuery.of(context).size.height / 2,
                  child: Transform.rotate(
                    angle: value * math.pi * 2,
                    child: Container(
                      width: particle['size'],
                      height: particle['size'],
                      decoration: BoxDecoration(
                        color: _glowColors[index % _glowColors.length],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _glowColors[index % _glowColors.length],
                            blurRadius: particle['size'] * 2,
                            spreadRadius: particle['size'],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // 发光球体效果
          ...List.generate(5, (index) {
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final value = _animationController.value;
                final offset = index * (math.pi / 2.5);
                final angle = (value * math.pi * 2) + offset;
                final radius = 150 + (math.sin(angle) * 50);

                return Positioned(
                  left: math.cos(angle) * radius +
                      MediaQuery.of(context).size.width / 2,
                  top: math.sin(angle) * radius +
                      MediaQuery.of(context).size.height / 2,
                  child: Transform.rotate(
                    angle: value * math.pi * 2,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _glowColors[index],
                            _glowColors[index].withOpacity(0),
                          ],
                        ),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 30 + (math.sin(angle) * 20),
                          sigmaY: 30 + (math.sin(angle) * 20),
                        ),
                        child: Container(),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // 主要内容
          widget.child,
        ],
      ),
    );
  }
}
