import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/language_service.dart';
import 'processing_screen.dart';
import 'package:image_cropper/image_cropper.dart';


class CameraInterface extends StatefulWidget {
  final String selectedCrop;
  const CameraInterface({super.key, required this.selectedCrop});

  @override
  State<CameraInterface> createState() => _CameraInterfaceState();
}

class _CameraInterfaceState extends State<CameraInterface> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  late AnimationController _scanAnimationController;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  late String _currentModel;

  @override
  void initState() {
    super.initState();
    _currentModel = widget.selectedCrop;
    _initializeCamera();
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scanAnimationController.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    if (_controller == null) return;
    setState(() {
      _isFlashOn = !_isFlashOn;
      _controller!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    });
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) return;

    try {
      final XFile image = await _controller!.takePicture();
      if (!mounted) return;
      
      final croppedPath = await _cropImage(image.path);
      if (croppedPath != null && mounted) {
        _navigateToResults(croppedPath);
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null && mounted) {
      final croppedPath = await _cropImage(image.path);
      if (croppedPath != null && mounted) {
        _navigateToResults(croppedPath);
      }
    }
  }

  void _navigateToResults(String path) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProcessingScreen(
          imagePath: path,
          cropName: _currentModel,
        ),
      ),
    );
  }

  Future<String?> _cropImage(String path) async {
    final langService = Provider.of<LanguageService>(context, listen: false);
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: langService.translate('Adjust Image', 'Sesuaikan Gambar'),
          toolbarColor: AppTheme.cardSurfaceDark,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppTheme.primaryTeal,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
          ],
        ),
        IOSUiSettings(
          title: langService.translate('Adjust Image', 'Sesuaikan Gambar'),
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
          ],
        ),
      ],
    );
    return croppedFile?.path;
  }

  void _showTips() {
    final langService = Provider.of<LanguageService>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardSurfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(langService.translate('Scanning Tips', 'Tips Memindai'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            _tipItem(
              LucideIcons.sun, 
              langService.translate('Good Lighting', 'Pencahayaan Baik'), 
              langService.translate('Ensure the leaf is well-lit but avoid direct glare.', 'Pastikan daun cukup terang namun hindari pantulan cahaya langsung.')
            ),
            _tipItem(
              LucideIcons.focus, 
              langService.translate('Steady Focus', 'Fokus Stabil'), 
              langService.translate('Hold your phone steady and keep the leaf in the frame.', 'Pegang ponsel Anda dengan stabil dan jaga daun tetap dalam bingkai.')
            ),
            _tipItem(
              LucideIcons.scanLine, 
              langService.translate('Correct Distance', 'Jarak yang Benar'), 
              langService.translate('Keep the camera 10-15cm away from the leaf.', 'Jaga jarak kamera 10-15cm dari daun.')
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(langService.translate('Got it', 'Dimengerti')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tipItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryTeal, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16)),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langService = Provider.of<LanguageService>(context);

    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          _buildCameraOverlay(),
          _buildTopControls(langService),
          _buildBottomControls(),
          _buildModelSelector(),
          _buildAIBadge(langService),
        ],
      ),
    );
  }

  Widget _buildCameraOverlay() {
    return Stack(
      children: [
        Center(
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24, width: 1),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        Center(
          child: SizedBox(
            width: 280,
            height: 280,
            child: const CustomPaint(painter: ViewfinderPainter()),
          ),
        ),
        AnimatedBuilder(
          animation: _scanAnimationController,
          builder: (context, child) {
            return Positioned(
              top: MediaQuery.of(context).size.height / 2 - 140 + (280 * _scanAnimationController.value),
              left: MediaQuery.of(context).size.width / 2 - 130,
              child: Container(
                width: 260,
                height: 2,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.8),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                  gradient: const LinearGradient(
                    colors: [Colors.transparent, AppTheme.primaryTeal, Colors.transparent],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTopControls(LanguageService langService) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 24,
      right: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _iconButton(LucideIcons.x, () => Navigator.pop(context), backgroundColor: Colors.transparent),
                Text(langService.translate('New Scan', 'Pindaian Baru'), style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.primaryTeal,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
                _iconButton(
                  _isFlashOn ? LucideIcons.zap : LucideIcons.zapOff, 
                  _toggleFlash, 
                  color: _isFlashOn ? Colors.yellow : Colors.white,
                  backgroundColor: Colors.transparent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    final iconColor = Colors.white;
    return Positioned(
      bottom: 30,
      left: 24,
      right: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _iconButton(LucideIcons.imagePlus, _pickFromGallery, size: 28, color: iconColor, backgroundColor: Colors.transparent),
                GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.5), width: 4),
                    ),
                    child: Center(
                      child: Container(
                        height: 64,
                        width: 64,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryTeal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.camera, color: Colors.white, size: 32),
                      ),
                    ),
                  ),
                ),
                _iconButton(LucideIcons.lightbulb, _showTips, size: 28, color: iconColor, backgroundColor: Colors.transparent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModelSelector() {
    return Positioned(
      bottom: 160,
      left: 80,
      right: 80,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 44,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                _selectorItem('rice', 'Rice', 'Padi'),
                _selectorItem('tomato', 'Tomato', 'Tomat'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectorItem(String id, String label, String labelId) {
    bool isSelected = _currentModel == id;
    final langService = Provider.of<LanguageService>(context);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentModel = id),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text(
            langService.translate(label, labelId),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIBadge(LanguageService langService) {
    return Positioned(
      top: MediaQuery.of(context).size.height / 2 - 180,
      left: 0,
      right: 0,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.cpu, color: AppTheme.primaryTeal, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    langService.translate('Analyzing symptoms on leaves...', 'Menganalisa gejala pada daun...'),
                    style: GoogleFonts.notoSans(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate(onPlay: (controller) => controller.repeat())
       .shimmer(duration: 2.seconds, color: AppTheme.primaryTeal.withValues(alpha: 0.3)),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap, {Color color = Colors.white, double size = 24, Color? backgroundColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.black26,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}

class ViewfinderPainter extends CustomPainter {
  const ViewfinderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryTeal
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const length = 24.0;
    const radius = 12.0;

    // Top Left
    canvas.drawPath(Path()
      ..moveTo(0, length)
      ..lineTo(0, radius)
      ..arcToPoint(const Offset(radius, 0), radius: const Radius.circular(radius))
      ..lineTo(length, 0), paint);

    // Top Right
    canvas.drawPath(Path()
      ..moveTo(size.width - length, 0)
      ..lineTo(size.width - radius, 0)
      ..arcToPoint(Offset(size.width, radius), radius: const Radius.circular(radius))
      ..lineTo(size.width, length), paint);

    // Bottom Left
    canvas.drawPath(Path()
      ..moveTo(0, size.height - length)
      ..lineTo(0, size.height - radius)
      ..arcToPoint(Offset(radius, size.height), radius: const Radius.circular(radius))
      ..lineTo(length, size.height), paint);

    // Bottom Right
    canvas.drawPath(Path()
      ..moveTo(size.width - length, size.height)
      ..lineTo(size.width - radius, size.height)
      ..arcToPoint(Offset(size.width, size.height - radius), radius: const Radius.circular(radius))
      ..lineTo(size.width, size.height - length), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
