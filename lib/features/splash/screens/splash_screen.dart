
import 'dart:async';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/helper/login_helper.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class SplashScreen extends StatefulWidget {
  final Map<String, dynamic>? notificationData;
  final String? userName;
  
  const SplashScreen({super.key, this.notificationData, this.userName});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;
  late AnimationController _controller;
  late AnimationController _particlesController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  final List<Particle> _particles = [];
  final Random _random = Random();
    StreamSubscription? _intentSub;

  @override
  void initState() {
    super.initState();

    // ✅ FIX 1 — Durées en millisecondes, pas microsecondes
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // ✅ FIX 2 — Particules lentes et fluides (10 secondes au lieu de 300µs)
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // ✅ FIX 3 — Moins de particules (50 au lieu de 100)
    _initializeParticles();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 0.9, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // ✅ FIX 4 — initSharedData en parallèle, ne bloque pas le Timer
    Get.find<ConfigController>().initSharedData();

    // ✅ FIX 5 — Timer raisonnable (2s pour laisser l'animation se voir)
    // Le splash minimum doit être visible : 1500ms à 2000ms est standard
    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        LoginHelper().handleIncomingLinks(
          widget.notificationData,
          widget.userName,
        );
      }
    });

    // ✅ FIX 6 — SUPPRIMÉ le listener setState() sur _particlesController
    // AnimatedBuilder dans le build() suffit et est bien plus efficace

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConnectivity();
    });

 ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      for (var file in value) {
        _handleSharedContent(file.message ?? '');
      }
      ReceiveSharingIntent.instance.reset();
    });

 // ✅ CAS 2 : App déjà ouverte et on partage vers elle
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      for (var file in value) {
        _handleSharedContent(file.message ?? '');
      }
    });

  }

  void _handleSharedContent(String sharedText) {
    // Google Maps partage sous ce format :
    // "https://maps.google.com/?q=5.3599517,−4.0082563"
    // ou "Lieu partagé : https://goo.gl/maps/xxx"

    final locationData = _extractLocationFromText(sharedText);
    if (locationData != null) {
      // Naviguer vers l'écran de ta destination avec les coordonnées
      Get.toNamed('/destination', arguments: locationData);
    }
  }
   Map<String, double>? _extractLocationFromText(String text) {
    // ✅ Extraire lat/lng d'une URL Google Maps
    final regExp = RegExp(r'q=([-\d.]+),([-\d.]+)');
    final match = regExp.firstMatch(text);
    if (match != null) {
      return {
        'lat': double.parse(match.group(1)!),
        'lng': double.parse(match.group(2)!),
      };
    }
    return null;
  }

  // ✅ FIX 7 — 50 particules au lieu de 100
  void _initializeParticles() {
    for (int i = 0; i < 50; i++) {
      _particles.add(Particle(random: _random));
    }
  }

  void _checkConnectivity() {
    bool isFirst = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> result) {
        if (!mounted) return;

        bool isConnected = result.contains(ConnectivityResult.wifi) ||
            result.contains(ConnectivityResult.mobile);

        if (!isFirst || !isConnected) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: isConnected ? Colors.green : Colors.red,
              duration: Duration(milliseconds: isConnected ? 1000 : 3000),
              content: Text(
                isConnected ? 'connected'.tr : 'no_connection'.tr,
                textAlign: TextAlign.center,
              ),
            ),
          );

          if (isConnected && !isFirst && mounted) {
            LoginHelper().handleIncomingLinks(
              widget.notificationData,
              widget.userName,
            );
          }
        }
        isFirst = false;
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _particlesController.dispose();
    _onConnectivityChanged?.cancel();
     _intentSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).primaryColor.withOpacity(0.6),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ✅ AnimatedBuilder suffit — pas besoin de setState() externe
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _particlesController,
                builder: (context, child) {
                  // Mise à jour des particules ICI, dans le builder
                  for (var particle in _particles) {
                    particle.update();
                  }
                  return CustomPaint(
                    painter: ParticlePainter(_particles),
                    size: Size.infinite,
                  );
                },
              ),
            ),

            ..._buildDecorativeCircles(),

            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double scale = _scaleAnimation.value;
                  if (_controller.value >= 0.7) {
                    scale *= (1.0 +
                        (_pulseAnimation.value - 1.0) *
                            ((_controller.value - 0.7) / 0.3));
                  }

                  return Transform.rotate(
                    angle: _rotationAnimation.value * 3.14159,
                    child: Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: SvgPicture.asset(
                          Images.splashSvgLogo,
                          width: 150,
                          height: 150,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
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

  List<Widget> _buildDecorativeCircles() {
    return List.generate(3, (index) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double progress =
              (_controller.value - 0.1 * (index + 1)).clamp(0.0, 0.8) / 0.8;

          if (_controller.value < 0.1 * (index + 1)) {
            return const SizedBox.shrink();
          }

          return Positioned(
            left: 50.0 + (index * 100.0),
            top: 100.0 + (index * 150.0),
            child: Opacity(
              opacity: (1.0 - progress) * 0.3,
              child: Transform.scale(
                scale: 1.0 + progress * 3,
                child: Container(
                  width: 30.0 + (index * 20.0),
                  height: 30.0 + (index * 20.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

class Particle {
  double x, y, size, speed, opacity, angle;
  final Random random;

  Particle({required this.random})
      : x = 0, y = 0, size = 0, speed = 0, opacity = 0, angle = 0 {
    _reset();
  }

  void _reset() {
    x = random.nextDouble() * 1.2 - 0.1;
    y = random.nextDouble() * 1.2 - 0.1;
    size = 1.0 + random.nextDouble() * 3.0;
    speed = 0.001 + random.nextDouble() * 0.005;
    opacity = 0.1 + random.nextDouble() * 0.3;
    angle = random.nextDouble() * 2 * pi;
  }

  void update() {
    angle += 0.001;
    x += sin(angle) * 0.0005;
    y += cos(angle) * 0.0005;
    if (x < -0.1 || x > 1.1 || y < -0.1 || y > 1.1) _reset();
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var particle in particles) {
      paint.color = Colors.white.withOpacity(particle.opacity);
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}