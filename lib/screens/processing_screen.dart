import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/tflite_service.dart';
import '../services/language_service.dart';
import '../models/detection_result.dart';
import 'result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String imagePath;
  final String cropName;

  const ProcessingScreen({
    super.key,
    required this.imagePath,
    required this.cropName,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  final TFLiteService _tfliteService = TFLiteService();
  String _statusMessage = 'Analyzing Specimen...';
  String _statusMessageId = 'Menganalisa Spesimen...';

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    // 1. Load Model
    setState(() {
      _statusMessage = 'Loading AI Models...';
      _statusMessageId = 'Memuat Model AI...';
    });
    await _tfliteService.loadModel(widget.cropName);

    // 2. Artificial delay for UX
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() {
      _statusMessage = 'Running classification...';
      _statusMessageId = 'Menjalankan klasifikasi...';
    });

    // 3. Classify
    final result = await _tfliteService.classifyImage(widget.imagePath);

    // 4. Artificial delay for UX
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _statusMessage = 'Generating treatment plan...';
      _statusMessageId = 'Membuat rencana perawatan...';
    });
    
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (result != null) {
      final detectionResult = MockDetectionData.getResultByDisease(
        widget.imagePath,
        widget.cropName,
        result['label'],
        confidence: result['confidence'],
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ResultScreen(result: detectionResult),
        ),
      );
    } else {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to analyze image. Please try again.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final langService = Provider.of<LanguageService>(context);

    return Scaffold(
      backgroundColor: Colors.black, // Dark fallback
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image
          Image.file(
            File(widget.imagePath),
            fit: BoxFit.cover,
          ),

          // 2. Glassmorphism Effect (Blur + Overlay)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Colors.black.withValues(alpha: 0.7), // Semi-transparent overlay
            ),
          ),

          // 3. Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: SizedBox(
                    width: 160,
                    height: 160,
                    child: Lottie.asset(
                      'assets/lottie/scanning.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  langService.translate(_statusMessage, _statusMessageId),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Text(
                    langService.translate(
                      'Applying deep learning models to identify the specific condition of your crop.',
                      'Menerapkan model deep learning untuk mengidentifikasi kondisi spesifik tanaman Anda.'
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 140,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white10,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}