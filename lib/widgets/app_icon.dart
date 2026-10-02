import 'package:flutter/material.dart';

class AppIcon extends StatefulWidget {
  final double size;
  final Color color;

  const AppIcon({super.key, required this.size, required this.color});

  @override
  State<AppIcon> createState() => _AppIconState();
}

class _AppIconState extends State<AppIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(painter: _HeartIconPainter(color: widget.color)),
          ),
        );
      },
    );
  }
}

class _HeartIconPainter extends CustomPainter {
  final Color color;

  _HeartIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final double width = size.width;
    final double height = size.height;

    final Path path = Path();
    path.moveTo(width * 0.5, height * 0.35);

    // Left curve
    path.cubicTo(
      width * 0.2,
      height * 0.1, // Control point 1
      width * -0.25,
      height * 0.6, // Control point 2
      width * 0.5,
      height * 0.95, // End point
    );

    // Right curve
    path.cubicTo(
      width * 1.25,
      height * 0.6, // Control point 1
      width * 0.8,
      height * 0.1, // Control point 2
      width * 0.5,
      height * 0.35, // End point
    );

    // Draw outline with a slight shadow
    canvas.drawShadow(path, Colors.black26, 4.0, true);
    canvas.drawPath(path, paint);

    // Draw a subtle highlight
    final Paint highlightPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.03;

    final Path highlightPath = Path();
    highlightPath.moveTo(width * 0.3, height * 0.25);
    highlightPath.quadraticBezierTo(
      width * 0.2,
      height * 0.2,
      width * 0.25,
      height * 0.4,
    );

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
