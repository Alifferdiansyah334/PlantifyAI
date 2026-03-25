import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/article.dart';
import '../theme/app_theme.dart';

class FeaturedArticle extends StatelessWidget {
  final Article article;
  final VoidCallback? onTap;
  final String? heroTag;

  const FeaturedArticle({
    super.key,
    required this.article,
    this.onTap,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Hero(
                tag: heroTag ?? 'article_image_${article.id}',
                child: _buildImage(),
              ),

              // Gradient Overlay
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black87,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'FEATURED',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ),
                    const Spacer(),
                    // Title
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 22,
                            height: 1.2,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Summary or Category
                    Text(
                      '${article.category} • ${article.readTime}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textMediumEmphasis,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (article.imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: article.imageUrl,
        fit: BoxFit.cover,
        memCacheWidth: 600,
        placeholder: (context, url) => Container(
          color: AppTheme.cardSurfaceDark,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppTheme.cardSurfaceDark,
          child: const Icon(Icons.image_not_supported,
              color: AppTheme.iconColorInactive),
        ),
      );
    } else if (article.imageUrl.startsWith('assets/')) {
      return Image.asset(
        article.imageUrl,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        cacheWidth: 600,
      );
    } else {
      return Image.file(
        File(article.imageUrl),
        fit: BoxFit.cover,
        cacheWidth: 600,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppTheme.cardSurfaceDark,
          child: const Icon(Icons.image_not_supported,
              color: AppTheme.iconColorInactive),
        ),
      );
    }
  }
}