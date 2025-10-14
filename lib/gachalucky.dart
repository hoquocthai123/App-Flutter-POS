import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class LuckyWheel extends StatefulWidget {
  const LuckyWheel({Key? key}) : super(key: key);

  @override
  State<LuckyWheel> createState() => _LuckyWheelState();
}

class _LuckyWheelState extends State<LuckyWheel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _angle = 0;
  bool isSpinning = false;
  int remainingSpins = 1;
  String? lastSpinDate;

  final List<Prize> prizes = [
    Prize("iPhone 17", 0.5, Colors.red),
    Prize("Voucher 100K", 10, Colors.blue),
    Prize("Voucher 20K", 20, Colors.green),
    Prize("Voucher 30K", 14.5, Colors.orange),
    Prize("Voucher 5K", 55, Colors.purple),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _controller.addListener(() {
      setState(() {
        _angle = _controller.value * 2 * math.pi * 10;
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isSpinning = false;
        });
        _showResult();
      }
    });

    _loadSpinData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSpinData() async {
    final prefs = await SharedPreferences.getInstance();
    lastSpinDate = prefs.getString('lastSpinDate');
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (lastSpinDate != today) {
      remainingSpins = 1;
      await prefs.setString('lastSpinDate', today);
    } else {
      remainingSpins = 0;
    }
    setState(() {});
  }

  void _showResult() {
    double normalizedAngle = _angle % (2 * math.pi);
    double cumulative = 0;
    Prize wonPrize = prizes.last;
    for (var prize in prizes) {
      cumulative += (prize.probability / 100) * 2 * math.pi;
      if (normalizedAngle < cumulative) {
        wonPrize = prize;
        break;
      }
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chúc mừng!'),
        content: Text('Bạn đã trúng: ${wonPrize.name}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _spinWheel() async {
    if (!isSpinning && remainingSpins > 0) {
      setState(() {
        isSpinning = true;
        remainingSpins--;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastSpinDate', DateFormat('yyyy-MM-dd').format(DateTime.now()));
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vòng Quay May Mắn'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lượt quay còn lại: $remainingSpins',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: _angle,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 5,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: WheelPainter(prizes),
                      ),
                    ),
                  ),
                  CustomPaint(
                    size: const Size(20, 40),
                    painter: PointerPainter(),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: (isSpinning || remainingSpins == 0) ? null : _spinWheel,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  backgroundColor: remainingSpins == 0 ? Colors.grey : Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 10,
                ),
                child: Text(
                  isSpinning ? 'Đang Quay...' : remainingSpins == 0 ? 'Hết lượt' : 'Quay',
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Prize {
  final String name;
  final double probability;
  final Color color;

  Prize(this.name, this.probability, this.color);
}

class WheelPainter extends CustomPainter {
  final List<Prize> prizes;

  WheelPainter(this.prizes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    double startAngle = 0;

    for (var prize in prizes) {
      final sweepAngle = (prize.probability / 100) * 2 * math.pi;
      paint.color = prize.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw text
      final textPainter = TextPainter(
        text: TextSpan(
          text: prize.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );

      textPainter.layout();
      final textAngle = startAngle + (sweepAngle / 2);
      final textCenter = Offset(
        center.dx + (radius * 0.6) * math.cos(textAngle),
        center.dy + (radius * 0.6) * math.sin(textAngle),
      );

      canvas.save();
      canvas.translate(textCenter.dx, textCenter.dy);
      canvas.rotate(textAngle + math.pi / 2);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}