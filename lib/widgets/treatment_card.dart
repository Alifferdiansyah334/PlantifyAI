import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/detection_result.dart';
import '../theme/app_theme.dart';
import '../services/language_service.dart';

class TreatmentCard extends StatelessWidget {
  final TreatmentPlan plan;
  final bool isOrganic;

  const TreatmentCard({
    super.key,
    required this.plan,
    required this.isOrganic,
  });

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final langService = Provider.of<LanguageService>(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOrganic 
              ? AppTheme.primaryTeal.withValues(alpha: 0.2) 
              : Colors.orange.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isOrganic ? AppTheme.primaryTeal : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isOrganic ? AppTheme.primaryTeal : Colors.orange).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isOrganic ? 'ORGANIC' : 'CHEMICAL',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white60,
                  ),
                ),
              ),
            ],
          ),
          if (plan.sourceUrl != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _launchUrl(plan.sourceUrl!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: (isOrganic ? AppTheme.primaryTeal : Colors.orange).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (isOrganic ? AppTheme.primaryTeal : Colors.orange).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.externalLink,
                      size: 14,
                      color: isOrganic ? AppTheme.primaryTeal : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      langService.translate('View Official Source', 'Lihat Sumber Resmi'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isOrganic ? AppTheme.primaryTeal : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (plan.duration.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: Colors.white38),
                const SizedBox(width: 8),
                Text(
                  '${langService.translate('Duration', 'Durasi')}: ${plan.duration}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Text(
            langService.translate('Steps', 'Langkah-langkah'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          ...plan.steps.map((step) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isOrganic ? AppTheme.primaryTeal : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}