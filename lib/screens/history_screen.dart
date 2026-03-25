import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';
import '../services/language_service.dart';
import '../services/detection_history_service.dart';
import '../models/detection_history.dart';
import '../models/detection_result.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'All'; // 'All', 'Healthy', 'Diseased'

  @override
  Widget build(BuildContext context) {
    final historyService = Provider.of<DetectionHistoryService>(context);
    final languageService = Provider.of<LanguageService>(context);
    final stats = historyService.getStats();
    final allHistory = historyService.history;

    // Filter logic
    final historyList = allHistory.where((item) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Healthy') {
        return item.resultStatus.toLowerCase() == 'healthy';
      }
      if (_selectedFilter == 'Diseased') {
        return item.resultStatus.toLowerCase() != 'healthy';
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.primaryDarkBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildStickyHeader(context, languageService),
            _buildStatsOverview(stats, languageService),
            Expanded(
              child: _buildHistoryList(historyList, context, languageService),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyHeader(BuildContext context, LanguageService languageService) {
    final canPop = Navigator.canPop(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: AppTheme.primaryDarkBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (canPop)
            IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            )
          else
            const SizedBox(width: 48),
          Text(
            languageService.translate('History', 'Riwayat'),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: Icon(
              _selectedFilter == 'All' ? LucideIcons.filter : LucideIcons.filterX,
              color: _selectedFilter == 'All' ? Colors.white : AppTheme.primaryTeal,
            ),
            onPressed: () {
              if (_selectedFilter != 'All') {
                setState(() => _selectedFilter = 'All');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(Map<String, int> stats, LanguageService languageService) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          _buildStatCard(
            languageService.translate('Total Scans', 'Total Pindai'), 
            stats['total'].toString(), 
            LucideIcons.barChart2, 
            null,
            filterType: 'All'
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            languageService.translate('Healthy', 'Sehat'), 
            stats['healthy'].toString(), 
            LucideIcons.sprout, 
            AppTheme.accentGreen,
            filterType: 'Healthy'
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            languageService.translate('Diseased', 'Sakit'), 
            stats['diseased'].toString(), 
            LucideIcons.alertTriangle, 
            AppTheme.redBadgeError,
            filterType: 'Diseased'
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color? color, {required String filterType}) {
    final isSelected = _selectedFilter == filterType;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterType;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? (color ?? AppTheme.primaryTeal).withValues(alpha: 0.2) 
              : AppTheme.cardSurfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? (color ?? AppTheme.primaryTeal) 
                : Colors.white.withValues(alpha: 0.05)
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (color ?? Colors.white).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color ?? Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: isSelected ? Colors.white : AppTheme.textMediumEmphasis,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(List<DetectionHistory> historyList, BuildContext context, LanguageService languageService) {
    if (historyList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.searchX, size: 48, color: AppTheme.textMediumEmphasis.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              languageService.translate('No items found', 'Item tidak ditemukan'),
              style: GoogleFonts.notoSans(color: AppTheme.textMediumEmphasis),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 20),
      itemCount: historyList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = historyList[index];
        final isHealthy = item.resultStatus.toLowerCase() == 'healthy';
        final statusColor = isHealthy ? AppTheme.accentGreen : AppTheme.redBadgeError;
        final double opacity = index > 5 ? 0.7 : 1.0; 

        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.horizontal,
          onDismissed: (direction) {
             Provider.of<DetectionHistoryService>(context, listen: false).deleteDetection(item.id);
             
             toastification.show(
               context: context,
               type: ToastificationType.success,
               style: ToastificationStyle.fillColored,
               title: Text(languageService.translate('Record deleted', 'Rekaman dihapus')),
               description: Text(languageService.translate(
                 'Successfully removed ${item.cropType} diagnosis',
                 'Berhasil menghapus diagnosis ${item.cropType}'
               )),
               alignment: Alignment.topCenter,
               autoCloseDuration: const Duration(seconds: 3),
               borderRadius: BorderRadius.circular(12),
               showProgressBar: true,
             );
          },
          background: Container(
            decoration: BoxDecoration(
              color: AppTheme.redBadgeError,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(LucideIcons.trash2, color: Colors.white),
          ),
          secondaryBackground: Container(
            decoration: BoxDecoration(
              color: AppTheme.redBadgeError,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(LucideIcons.trash2, color: Colors.white),
          ),
          child: GestureDetector(
            onTap: () {
              // Reconstruct DetectionResult
              final result = MockDetectionData.getResultByDisease(
                item.imageUrl,
                item.cropType,
                item.diseaseName,
                confidence: item.confidence,
              );
              
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ResultScreen(
                  result: result,
                  isHistoryMode: true,
                  detectionId: item.id,
                )),
              );
            },
            child: Opacity(
              opacity: opacity,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(item.imageUrl),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: AppTheme.primaryDarkBackground,
                              child: const Icon(Icons.broken_image, size: 20, color: Colors.white54),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppTheme.cardSurfaceDark,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.cropType.toLowerCase() == 'rice' ? LucideIcons.wheat : LucideIcons.flower,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.cropType,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${item.diseaseName} • ${(item.confidence * 100).toInt()}%',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 12,
                                    color: AppTheme.textMediumEmphasis,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(LucideIcons.chevronRight, color: AppTheme.textMediumEmphasis, size: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
