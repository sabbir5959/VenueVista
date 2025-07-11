import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _backgroundController;
  late AnimationController _progressController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation controller (2.5 seconds total)
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Background animation controller
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Progress animation controller
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo animations (0ms - 1200ms)
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.48, curve: Curves.elasticOut),
      ),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _logoSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.0, 0.48, curve: Curves.elasticOut),
          ),
        );

    // Text animations (600ms - 1800ms)
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.24, 0.72, curve: Curves.easeOut),
      ),
    );

    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.24, 0.72, curve: Curves.easeOutCubic),
          ),
        );

    // Background gradient animation
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    // Progress animation
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start background animation
    _backgroundController.repeat(reverse: true);

    // Start main animation
    _mainController.forward();

    // Start progress after 500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _progressController.forward();
      }
    });

    // Navigate to login after all animations complete
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _backgroundController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    AppColors.primary,
                    AppColors.primaryLight,
                    _backgroundAnimation.value * 0.3,
                  )!,
                  AppColors.primary,
                  Color.lerp(
                    AppColors.primary,
                    AppColors.primaryDark,
                    _backgroundAnimation.value * 0.4,
                  )!,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo Section
                    AnimatedBuilder(
                      animation: _mainController,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _logoSlideAnimation,
                          child: FadeTransition(
                            opacity: _logoOpacityAnimation,
                            child: ScaleTransition(
                              scale: _logoScaleAnimation,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.white.withOpacity(0.15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.black.withOpacity(0.2),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                      spreadRadius: 5,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: AppColors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.location_city,
                                    size: 70,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 50),

                    // Animated Text Section
                    AnimatedBuilder(
                      animation: _mainController,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _textSlideAnimation,
                          child: FadeTransition(
                            opacity: _textFadeAnimation,
                            child: Column(
                              children: [
                                // App Name with subtle glow effect
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: AppColors.white.withOpacity(0.1),
                                    border: Border.all(
                                      color: AppColors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'VenueVista',
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.white,
                                      letterSpacing: 1.5,
                                      shadows: [
                                        Shadow(
                                          color: AppColors.black.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Tagline
                                Text(
                                  'Your Ultimate Venue Booking Experience',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 40),

                                // Modern Progress Indicator
                                AnimatedBuilder(
                                  animation: _progressAnimation,
                                  builder: (context, child) {
                                    return Column(
                                      children: [
                                        Container(
                                          width: 250,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                            color: AppColors.white.withOpacity(
                                              0.2,
                                            ),
                                          ),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 100,
                                              ),
                                              width:
                                                  250 *
                                                  _progressAnimation.value,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.white,
                                                    AppColors.white.withOpacity(
                                                      0.8,
                                                    ),
                                                  ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.white
                                                        .withOpacity(0.4),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 20),

                                        // Loading Text with smooth opacity
                                        AnimatedOpacity(
                                          opacity:
                                              0.6 +
                                              (0.4 * _progressAnimation.value),
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          child: Text(
                                            'Loading your experience...',
                                            style: TextStyle(
                                              color: AppColors.white
                                                  .withOpacity(0.8),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w300,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
