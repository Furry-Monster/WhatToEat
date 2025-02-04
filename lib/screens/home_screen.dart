import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:witch_one/theme/colors.dart';
import 'package:witch_one/services/storage_service.dart';
import 'package:witch_one/models/food_item.dart';
import 'package:witch_one/widgets/selection_result_dialog.dart';
import 'package:witch_one/widgets/animated_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final StorageService _storage = StorageService();
  String _selectedFood = '点击按钮开始选择';
  bool _isSelecting = false;
  late final AnimationController _animationController;
  FragmentShader? _shader;
  Offset _mousePosition = Offset.zero;

  // 添加粒子效果
  List<Map<String, dynamic>> _particles = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // 初始化粒子
    _initParticles();
    _loadShader();
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

  Future<void> _loadShader() async {
    try {
      final program =
          await FragmentProgram.fromAsset('assets/shaders/ray_trace.frag');
      if (mounted) {
        setState(() {
          _shader = program.fragmentShader();
        });
      }
    } catch (e) {
      debugPrint('Shader loading error: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startSelection() async {
    setState(() {
      _isSelecting = true;
    });

    // 模拟随机选择动画
    int count = 0;
    const duration = Duration(milliseconds: 100);
    final options = await _storage.getFoodOptions();
    if (options.isEmpty) {
      setState(() {
        _isSelecting = false;
        _selectedFood = '没有可选择的食物';
      });
      return;
    }

    void selectRandomly() async {
      if (count < 20) {
        final randomFood = options[math.Random().nextInt(options.length)];
        setState(() {
          _selectedFood = randomFood;
        });
        count++;
        Future.delayed(duration, selectRandomly);
      } else {
        // 显示选择结果对话框
        if (!mounted) return;
        final price = await showDialog<double>(
          context: context,
          barrierDismissible: false,
          builder: (context) => SelectionResultDialog(foodName: _selectedFood),
        );

        // 记录到历史
        final selectedItem = FoodItem(
          name: _selectedFood,
          timestamp: DateTime.now(),
          price: price, // 添加价格
        );
        await _storage.addToHistory(selectedItem);

        setState(() {
          _isSelecting = false;
        });
      }
    }

    selectRandomly();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今天吃什么？'),
        automaticallyImplyLeading: false,
      ),
      body: AnimatedBackground(
        child: Stack(
          children: [
            if (_shader != null)
              MouseRegion(
                onHover: (event) {
                  setState(() {
                    _mousePosition = event.localPosition;
                  });
                },
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ShaderPainter(
                        shader: _shader!,
                        time: _animationController.value,
                        mousePosition: _mousePosition,
                      ),
                      size: Size.infinite,
                    );
                  },
                ),
              ),
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0.0,
                  end: _isSelecting ? 1.0 : 0.0,
                ),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 1.0 + (value * 0.05),
                    child: Card(
                      margin: const EdgeInsets.all(24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary
                                      .withOpacity(0.5 + (value * 0.3)),
                                  AppColors.secondary
                                      .withOpacity(0.5 + (value * 0.3)),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withOpacity(0.2 + (value * 0.3)),
                                  blurRadius: 20 + (value * 20),
                                  spreadRadius: 5 + (value * 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                    begin: 0.0,
                                    end: _isSelecting ? 1.0 : 0.0,
                                  ),
                                  duration: const Duration(milliseconds: 300),
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: 1.0 +
                                          (math.sin(value * math.pi * 2) *
                                              0.05),
                                      child: Text(
                                        _selectedFood,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              color: AppColors.onBackground,
                                              fontWeight: FontWeight.bold,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 30),
                                ElevatedButton(
                                  onPressed:
                                      _isSelecting ? null : _startSelection,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.white.withOpacity(0.2),
                                    foregroundColor: AppColors.onBackground,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                  ),
                                  child: Text(
                                    _isSelecting ? '选择中...' : '开始选择',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShaderPainter extends CustomPainter {
  final FragmentShader shader;
  final double time;
  final Offset mousePosition;

  ShaderPainter({
    required this.shader,
    required this.time,
    required this.mousePosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);
    shader.setFloat(3, mousePosition.dx);
    shader.setFloat(4, mousePosition.dy);

    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(ShaderPainter oldDelegate) => true;
}
