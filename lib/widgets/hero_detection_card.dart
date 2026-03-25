import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../screens/select_crop_screen.dart';
import '../services/language_service.dart';

class HeroDetectionCard extends StatelessWidget {
  const HeroDetectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final langService = Provider.of<LanguageService>(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cardSurfaceDark,
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cardSurfaceDark,
            AppTheme.cardSurfaceDark.withValues(alpha: 0.8),
            AppTheme.primaryDarkBackground,
          ],
        ),
        boxShadow: [
           BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ]
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.center_focus_strong_outlined,
                    color: AppTheme.primaryTeal,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 32,
                  child: _BackspaceTypewriterText(
                    texts: [
                      langService.translate('Detect Disease', 'Deteksi Penyakit'),
                      langService.translate('Scan Your Plants', 'Pindai Tanamanmu'),
                      langService.translate('Heal Your Crops', 'Obati Tanamanmu'),
                      langService.translate('Identify Issues', 'Kenali Masalah'),
                    ],
                    style: Theme.of(context).textTheme.displayLarge!,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  langService.translate(
                    'Found a spot on a leaf? Scan your crops to instantly identify diseases and get treatment plans.',
                    'Menemukan bercak pada daun? Pindai tanaman Anda untuk mengidentifikasi penyakit secara instan dan dapatkan rencana perawatan.'
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SelectCropScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: Text(langService.translate('Start Scan', 'Mulai Pindai')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: AppTheme.textLight,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .shimmer(delay: 1500.ms, duration: 1500.ms, color: Colors.white.withValues(alpha: 0.2))
                 .scale(
                   begin: const Offset(1, 1), 
                   end: const Offset(1.02, 1.02), 
                   duration: 1000.ms, 
                   curve: Curves.easeInOut
                 ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.redBadgeError.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.redBadgeError.withValues(alpha: 0.5)),
              ),
              child: Text(
                langService.translate('AI Active', 'AI Aktif'),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.redBadgeError,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackspaceTypewriterText extends StatefulWidget {
  final List<String> texts;
  final TextStyle style;
  final Duration typingSpeed;
  final Duration deletingSpeed;
  final Duration pause;

  const _BackspaceTypewriterText({
    required this.texts,
    required this.style,
    this.typingSpeed = const Duration(milliseconds: 100),
    this.deletingSpeed = const Duration(milliseconds: 50),
    this.pause = const Duration(milliseconds: 2000),
  });

  @override
  State<_BackspaceTypewriterText> createState() => _BackspaceTypewriterTextState();
}

class _BackspaceTypewriterTextState extends State<_BackspaceTypewriterText> {
  String _currentText = '';
  int _textIndex = 0;
  bool _isDeleting = false;
  Timer? _timer;
  bool _showCursor = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _showCursor = !_showCursor;
      });
    });
  }

  void _startAnimation() {
    if (!mounted) return;

    final fullText = widget.texts[_textIndex];
    
    if (_isDeleting) {
      if (_currentText.isEmpty) {
        setState(() {
          _isDeleting = false;
          _textIndex = (_textIndex + 1) % widget.texts.length;
        });
        _timer = Timer(const Duration(milliseconds: 500), _startAnimation);
      } else {
        setState(() {
          _currentText = fullText.substring(0, _currentText.length - 1);
        });
        _timer = Timer(widget.deletingSpeed, _startAnimation);
      }
    } else {
      if (_currentText.length == fullText.length) {
        _timer = Timer(widget.pause, () {
          if (mounted) {
            setState(() {
              _isDeleting = true;
            });
            _startAnimation();
          }
        });
      } else {
        setState(() {
          _currentText = fullText.substring(0, _currentText.length + 1);
        });
        _timer = Timer(widget.typingSpeed, _startAnimation);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$_currentText${_showCursor ? '_' : ' '}',
      style: widget.style,
    );
  }
}