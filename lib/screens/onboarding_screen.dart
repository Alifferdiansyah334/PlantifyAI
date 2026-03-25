import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', false);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDarkBackground,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: 3,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildPage(index)
                  .animate(key: ValueKey(index)) // Key to trigger animation on change
                  .fadeIn(duration: 600.ms);
            },
          ),
          
          // Skip Button
          if (_currentPage > 0)
            Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  'Skip',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                ),
              ),
            ),

          // Bottom Navigation Area
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 3,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: AppTheme.primaryTeal,
                    dotColor: AppTheme.cardSurfaceDark,
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 8,
                  ),
                ),
                const SizedBox(height: 32),
                _buildCTAButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButton() {
    String text;
    VoidCallback onPressed;

    switch (_currentPage) {
      case 0:
        text = 'Get Started';
        onPressed = () {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        };
        break;
      case 1:
        text = 'Next Step';
        onPressed = () {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        };
        break;
      case 2:
      default:
        text = 'Continue';
        onPressed = _completeOnboarding;
        break;
    }

    return Hero(
      tag: 'onboarding_cta',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Ink(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                text,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDarkBackground,
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(delay: 400.ms, duration: 600.ms)
      .shimmer(delay: 1000.ms, duration: 1500.ms, color: Colors.white.withValues(alpha: 0.2));
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildPage1();
      case 1:
        return _buildPage2();
      case 2:
        return _buildPage3();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPage1() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildScannerVisual(),
          const SizedBox(height: 48),
          _buildTextContent(
            "Diagnose Plants with AI Power",
            "Protect your rice and tomato yields. Identify diseases in seconds with just one photo.",
          ),
          const SizedBox(height: 80), // Space for bottom area
        ],
      ),
    );
  }

  Widget _buildScannerVisual() {
    return Container(
      width: 280,
      height: 360,
      decoration: BoxDecoration(
        color: AppTheme.cardSurfaceDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Placeholder for leaf_veins_macro
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/soil_health.jpg', // Using existing asset as placeholder
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.3),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // Scanning Line
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return Positioned(
                top: 360 * _scanAnimation.value,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryTeal,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Live Scan HUD Overlay
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryTeal,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LIVE SCAN',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppTheme.primaryTeal,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }

  Widget _buildPage2() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildViewfinderVisual(),
          const SizedBox(height: 48),
          _buildTextContent(
            "Fast Diagnosis",
            "Simply capture a photo of the affected rice or tomato plant. Our AI analyzes leaf patterns to detect diseases in seconds.",
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildViewfinderVisual() {
    return Container(
      width: 280,
      height: 360,
      decoration: BoxDecoration(
        color: AppTheme.cardSurfaceDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
           ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/rice_blast.jpg', // Placeholder
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // Viewfinder corners
          ..._buildCorner(top: 20, left: 20, rotation: 0),
          ..._buildCorner(top: 20, right: 20, rotation: 90),
          ..._buildCorner(bottom: 20, right: 20, rotation: 180),
          ..._buildCorner(bottom: 20, left: 20, rotation: 270),
          
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Analyzing patterns...',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }

  List<Widget> _buildCorner({double? top, double? bottom, double? left, double? right, required double rotation}) {
    return [
      Positioned(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: Transform.rotate(
          angle: rotation * 3.14159 / 180,
          child: SizedBox(
            width: 40,
            height: 40,
            child: CustomPaint(
              painter: CornerPainter(color: AppTheme.primaryTeal),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildPage3() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFeatureShowcaseVisual(),
          const SizedBox(height: 48),
          _buildTextContent(
            "Do more with Plantify",
            "All-in-one plant care companion.",
          ),
           const SizedBox(height: 24),
           // Feature List
           _buildFeatureItem(LucideIcons.bookOpen, "Articles & Tips", "Expert care guides for crops."),
           const SizedBox(height: 16),
           _buildFeatureItem(LucideIcons.history, "Detection History", "Track disease progression over time."),
           const SizedBox(height: 16),
           _buildFeatureItem(LucideIcons.bot, "AI Analysis", "Instant diagnosis with good accuracy."),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
  
  Widget _buildFeatureItem(IconData icon, String title, String desc) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryTeal, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                desc,
                style: GoogleFonts.notoSans(
                  color: AppTheme.textMediumEmphasis,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2, end: 0, curve: Curves.easeOut);
  }

  Widget _buildFeatureShowcaseVisual() {
    return Container(
      width: 280,
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.cardSurfaceDark,
        borderRadius: BorderRadius.circular(24),
         boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/fresh_tomatoes.jpg', // Placeholder
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // Grid Overlay
          Container(
             decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
             ),
          ),
           Center(
             child: Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: Colors.white.withValues(alpha: 0.2),
                 shape: BoxShape.circle,
                 border: Border.all(color: Colors.white, width: 2),
               ),
               child: const Icon(LucideIcons.scanLine, color: Colors.white, size: 32),
             ),
           ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }

  Widget _buildTextContent(String title, String description) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textLight,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSans(
            fontSize: 16,
            color: AppTheme.textMediumEmphasis,
            height: 1.5,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }
}

class CornerPainter extends CustomPainter {
  final Color color;

  CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
