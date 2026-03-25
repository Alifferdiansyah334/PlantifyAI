import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/detection_result.dart';
import '../models/detection_history.dart';
import '../theme/app_theme.dart';
import '../widgets/confidence_ring.dart';
import '../widgets/treatment_card.dart';
import '../services/language_service.dart';
import '../services/detection_history_service.dart';
import '../services/pdf_service.dart';

class ResultScreen extends StatefulWidget {
  final DetectionResult result;
  final bool isHistoryMode;
  final String? detectionId;

  const ResultScreen({
    super.key,
    required this.result,
    this.isHistoryMode = false,
    this.detectionId,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  bool _isSharing = false;
  final int _imageCount = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (_currentPage < _imageCount - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _shareReport() async {
    setState(() => _isSharing = true);
    try {
      final pdfService = PdfService();
      // Show loading toast or indicator if needed, but the button state might be enough
      
      final file = await pdfService.generateReport(widget.result);
      
      if (!mounted) return;

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Plantify Disease Report: ${widget.result.diseaseName}',
        subject: 'Plantify Report - ${widget.result.cropName}',
      );
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          title: const Text('Share Failed'),
          description: Text(e.toString()),
          alignment: Alignment.topCenter,
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardSurfaceDark,
        title: Text(
          'Delete Record?',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to remove this detection from your history?',
          style: GoogleFonts.notoSans(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          TextButton(
            onPressed: () {
              if (widget.detectionId != null) {
                Provider.of<DetectionHistoryService>(
                  context,
                  listen: false,
                ).deleteDetection(widget.detectionId!);

                toastification.show(
                  context: context,
                  type: ToastificationType.success,
                  style: ToastificationStyle.fillColored,
                  title: const Text('Record deleted'),
                  description: const Text('Diagnosis removed from history'),
                  alignment: Alignment.topCenter,
                  autoCloseDuration: const Duration(seconds: 3),
                  borderRadius: BorderRadius.circular(12),
                  showProgressBar: true,
                );
              }
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.redBadgeError),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langService = Provider.of<LanguageService>(context);

    return Scaffold(
      backgroundColor: AppTheme.primaryDarkBackground,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResultHeader(context, langService),
                  const SizedBox(height: 24),
                  if (widget.result.highlight != null) ...[
                    _buildHighlightSection(context, langService),
                    const SizedBox(height: 32),
                  ],
                  _buildExampleCarousel(context, langService),
                  const SizedBox(height: 32),
                  _buildSymptomsSection(context, langService),
                  const SizedBox(height: 32),
                  _buildTreatmentSection(context, langService),
                  const SizedBox(height: 40),
                  _buildActionButtons(context, langService),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppTheme.primaryDarkBackground,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        if (widget.isHistoryMode)
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: AppTheme.redBadgeError),
            onPressed: () => _confirmDelete(context),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: widget.result.imagePath,
              child: Image.file(
                File(widget.result.imagePath),
                fit: BoxFit.cover,
                cacheWidth: 800,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.primaryDarkBackground.withValues(alpha: 0.2),
                    AppTheme.primaryDarkBackground,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultHeader(BuildContext context, LanguageService langService) {
    String severityLabel = widget.result.severity;
    if (langService.isIndonesian) {
      if (severityLabel == 'High') severityLabel = 'Tinggi';
      if (severityLabel == 'Moderate') severityLabel = 'Sedang';
      if (severityLabel == 'Low') severityLabel = 'Rendah';
      if (severityLabel == 'Critical') severityLabel = 'Kritis';
      if (severityLabel == 'None') severityLabel = 'Tidak Ada';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      widget.result.severity == 'High' ||
                          widget.result.severity == 'Critical'
                      ? AppTheme.redBadgeError.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        widget.result.severity == 'High' ||
                            widget.result.severity == 'Critical'
                        ? AppTheme.redBadgeError
                        : Colors.orange,
                  ),
                ),
                child: Text(
                  '$severityLabel ${langService.translate('Severity', 'Tingkat Keparahan')}',
                  style: GoogleFonts.roboto(
                    color:
                        widget.result.severity == 'High' ||
                            widget.result.severity == 'Critical'
                        ? AppTheme.redBadgeError
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.result.diseaseName,
                style: Theme.of(context).textTheme.displayLarge,
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
              const SizedBox(height: 8),
              Text(
                '${langService.translate('Detected on', 'Terdeteksi pada')} ${langService.translate(widget.result.cropName, widget.result.cropName == 'Tomato' ? 'Tomat' : 'Padi')}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white60),
              ),
            ],
          ),
        ),
        ConfidenceRing(
          confidence: widget.result.confidence,
          color: AppTheme.accentGreen,
        ).animate().scale(delay: 300.ms, curve: Curves.easeOutBack),
      ],
    );
  }

  Widget _buildExampleCarousel(
    BuildContext context,
    LanguageService langService,
  ) {
    final String basePath =
        'assets/images/examples/${widget.result.cropName.toLowerCase()}/${widget.result.rawLabel}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              langService.translate('Reference Images', 'Gambar Referensi'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              langService.translate('Sample leaves', 'Contoh daun'),
              style: GoogleFonts.roboto(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _imageCount,
            itemBuilder: (context, index) {
              final String assetPath = '$basePath/${index + 1}.jpg';
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  cacheWidth: 600,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.image,
                            color: Colors.white10,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add ${index + 1}.jpg to\n${widget.result.rawLabel}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                              color: Colors.white24,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _imageCount,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 6),
              height: 6,
              width: _currentPage == index ? 20 : 6,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppTheme.primaryTeal
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 350.ms).slideX(begin: 0.1);
  }

  Widget _buildSymptomsSection(
    BuildContext context,
    LanguageService langService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          langService.translate('Symptoms Overview', 'Ringkasan Gejala'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Text(
          widget.result.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
        const SizedBox(height: 16),
        ...widget.result.symptoms.map(
          (symptom) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  LucideIcons.alertCircle,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    symptom,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildTreatmentSection(
    BuildContext context,
    LanguageService langService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          langService.translate('Treatment Plan', 'Rencana Perawatan'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 20),
        TreatmentCard(plan: widget.result.organicTreatment, isOrganic: true),
        const SizedBox(height: 16),
        TreatmentCard(plan: widget.result.chemicalTreatment, isOrganic: false),
      ],
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1);
  }

  Widget _buildHighlightSection(
    BuildContext context,
    LanguageService langService,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.withValues(alpha: 0.15),
            AppTheme.primaryTeal.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.5),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  LucideIcons.flaskConical,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      langService.translate('KEY INSIGHT', 'SOROTAN UTAMA'),
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.amber,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      langService.translate('Important Note', 'Catatan Penting'),
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.amber.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
            ),
            child: Text(
              widget.result.highlight!,
              style: GoogleFonts.notoSans(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 15,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (widget.result.highlightUrl != null) ...[
            const SizedBox(height: 24),
            InkWell(
              onTap: () => _launchUrl(widget.result.highlightUrl!),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      langService.translate(
                        'Read Official Source',
                        'Baca Sumber Resmi',
                      ),
                      style: GoogleFonts.notoSans(
                        color: Colors.amber,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      LucideIcons.externalLink,
                      color: Colors.amber,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildActionButtons(
    BuildContext context,
    LanguageService langService,
  ) {
    if (widget.isHistoryMode) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _isSharing ? null : _shareReport,
          icon: _isSharing 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
            : const Icon(LucideIcons.share2),
          label: Text(langService.translate('Share Report', 'Bagikan Laporan')),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white24),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isSharing ? null : _shareReport,
            icon: _isSharing 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
              : const Icon(LucideIcons.share2),
            label: Text(
              langService.translate('Share Report', 'Bagikan Laporan'),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              final historyService = Provider.of<DetectionHistoryService>(
                context,
                listen: false,
              );

              final newHistory = DetectionHistory(
                id: DateTime.now().millisecondsSinceEpoch.toString(),

                cropType: widget.result.cropName,

                resultStatus:
                    widget.result.rawLabel.toLowerCase().contains('healthy')
                    ? 'Healthy'
                    : 'Diseased',

                confidence: widget.result.confidence,

                date: DateTime.now().toIso8601String(),

                imageUrl: widget.result.imagePath,

                diseaseName: widget.result.diseaseName,
              );

              historyService.addDetection(newHistory);

              toastification.show(
                context: context,

                type: ToastificationType.success,

                style: ToastificationStyle.fillColored,

                title: Text(
                  langService.translate(
                    'Saved to History',
                    'Berhasil Disimpan',
                  ),
                ),

                description: Text(
                  langService.translate(
                    'Detection added to your library',
                    'Diagnosa telah ditambahkan ke pustaka',
                  ),
                ),

                alignment: Alignment.topCenter,

                autoCloseDuration: const Duration(seconds: 3),

                borderRadius: BorderRadius.circular(12),

                showProgressBar: true,
              );
            },

            icon: const Icon(LucideIcons.save),

            label: Text(
              langService.translate('Save to Library', 'Simpan ke Pustaka'),
            ),

            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,

              foregroundColor: Colors.white,

              padding: const EdgeInsets.symmetric(vertical: 16),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
