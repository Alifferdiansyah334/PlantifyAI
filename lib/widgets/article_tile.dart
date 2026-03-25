import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/article.dart';
import '../theme/app_theme.dart';

class ArticleTile extends StatelessWidget {
  final Article article;
  final VoidCallback? onTap;
  final String? heroTag;

  const ArticleTile({
    super.key,
    required this.article,
    this.onTap,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.cardSurfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 96,
                height: 96,
                child: Hero(
                  tag: heroTag ?? 'article_image_${article.id}',
                  child: _buildImage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    article.category.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.primaryTeal,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          height: 1.2,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppTheme.textMediumEmphasis,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        article.readTime,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (article.imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: article.imageUrl,
        fit: BoxFit.cover,
        memCacheWidth: 200,
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[800],
          child: const Icon(Icons.broken_image, size: 20),
        ),
      );
    } else if (article.imageUrl.startsWith('assets/')) {
      return Image.asset(
        article.imageUrl,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        cacheWidth: 200,
      );
    } else {
      // Handle local file from image_picker
      return Image.file(
        File(article.imageUrl),
        fit: BoxFit.cover,
        cacheWidth: 200,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[800],
          child: const Icon(Icons.broken_image, size: 20),
        ),
      );
    }
  }
}