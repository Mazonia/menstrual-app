import 'dart:math';
import 'package:flutter/material.dart';

class ParticleBackground extends StatefulWidget {
  final Color color;
  final int numberOfParticles;

  const ParticleBackground({
    super.key,
    required this.color,
    this.numberOfParticles = 30,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with TickerProviderStateMixin {
  late List<Particle> particles;
  late AnimationController _animationController;
  final Random random = Random();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _initializeParticles();
  }

  void _initializeParticles() {
    particles = List.generate(
      widget.numberOfParticles,
      (_) => Particle(
        position: Offset(random.nextDouble(), random.nextDouble()),
        speed: Offset(
          (random.nextDouble() - 0.5) * 0.01,
          (random.nextDouble() - 0.5) * 0.01,
        ),
        radius: random.nextDouble() * 3 + 1,
        opacity: random.nextDouble() * 0.6 + 0.2,
      ),
    );
  }

  @override
  void didUpdateWidget(ParticleBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color ||
        oldWidget.numberOfParticles != widget.numberOfParticles) {
      _initializeParticles();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        _updateParticlesPositions();
        return CustomPaint(
          painter: ParticlePainter(particles: particles, color: widget.color),
          size: Size.infinite,
        );
      },
    );
  }

  void _updateParticlesPositions() {
    for (final particle in particles) {
      particle.position += particle.speed;

      // Wrap around the screen edges
      if (particle.position.dx < 0) {
        particle.position = Offset(1, particle.position.dy);
      } else if (particle.position.dx > 1) {
        particle.position = Offset(0, particle.position.dy);
      }

      if (particle.position.dy < 0) {
        particle.position = Offset(particle.position.dx, 1);
      } else if (particle.position.dy > 1) {
        particle.position = Offset(particle.position.dx, 0);
      }
    }
  }
}

class Particle {
  Offset position;
  Offset speed;
  double radius;
  double opacity;

  Particle({
    required this.position,
    required this.speed,
    required this.radius,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Color color;

  ParticlePainter({required this.particles, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint =
          Paint()
            ..color = color.withOpacity(particle.opacity)
            ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(
          particle.position.dx * size.width,
          particle.position.dy * size.height,
        ),
        particle.radius,
        paint,
      );
    }

    // Draw connections between nearby particles
    _drawConnections(canvas, size);
  }

  void _drawConnections(Canvas canvas, Size size) {
    const maxDistance = 0.15; // Maximum distance for drawing connections

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final dx = (particles[i].position.dx - particles[j].position.dx).abs();
        final dy = (particles[i].position.dy - particles[j].position.dy).abs();

        if (dx < maxDistance && dy < maxDistance) {
          final distance = sqrt(dx * dx + dy * dy);
          final opacity = (1 - distance / maxDistance) * 0.3;

          final paint =
              Paint()
                ..color = color.withOpacity(opacity)
                ..strokeWidth = 0.5;

          canvas.drawLine(
            Offset(
              particles[i].position.dx * size.width,
              particles[i].position.dy * size.height,
            ),
            Offset(
              particles[j].position.dx * size.width,
              particles[j].position.dy * size.height,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
