import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/article.dart';
import '../theme/app_theme.dart';
import 'select_crop_screen.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;
  final String? heroTag;

  const ArticleDetailScreen({
    super.key,
    required this.article,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildHeader(context),
                      const SizedBox(height: 24),
                      _buildAuthorProfile(context),
                      const SizedBox(height: 32),
                      _buildRichContent(context),
                      const SizedBox(height: 32),
                      _buildInfoBox(context),
                      const SizedBox(height: 100), // Space for floating footer
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildFloatingFooter(context),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.primaryDarkBackground,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),            child: const Icon(LucideIcons.share2, color: Colors.white, size: 20),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: heroTag ?? 'article_image_${article.id}',
          child: _buildBackgroundImage(),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    if (article.imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: article.imageUrl,
        fit: BoxFit.cover,
        memCacheWidth: 800,
      );
    } else if (article.imageUrl.startsWith('assets/')) {
      return Image.asset(
        article.imageUrl,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        cacheWidth: 800,
      );
    } else {
      return Image.file(
        File(article.imageUrl),
        fit: BoxFit.cover,
        cacheWidth: 800,
      );
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.2)),
          ),
          child: Text(
            article.category.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.primaryTeal,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          article.title,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                height: 1.1,
                fontSize: 28,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(LucideIcons.calendar,
                size: 16, color: AppTheme.textMediumEmphasis),
            const SizedBox(width: 8),
            Text(
              article.date,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
            ),
            const SizedBox(width: 16),
            Icon(LucideIcons.clock,
                size: 16, color: AppTheme.textMediumEmphasis),
            const SizedBox(width: 8),
            Text(
              article.readTime,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAuthorProfile(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryTeal, width: 2),
          ),
          child: const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage('assets/images/profile_pic.png'), 
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.authorName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              article.authorRole,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryTeal,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRichContent(BuildContext context) {
    // Basic implementation of DropCap and formatted text
    // Splitting first letter for DropCap
    String firstLetter = article.content.substring(0, 1);
    String remainingText = article.content.substring(1);

    // Naive scientific name detection (text in parentheses)
    // For production, use a more robust parser
    List<InlineSpan> spans = [];
    
    // Simple parser for scientific names inside parentheses to italicize them
    RegExp exp = RegExp(r'\(([^)]+)\)');
    Iterable<RegExpMatch> matches = exp.allMatches(remainingText);
    
    int lastMatchEnd = 0;
    
    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: remainingText.substring(lastMatchEnd, match.start)));
      }
      spans.add(TextSpan(
        text: '(${match.group(1)})',
        style: GoogleFonts.newsreader(fontStyle: FontStyle.italic),
      ));
      lastMatchEnd = match.end;
    }
    
    if (lastMatchEnd < remainingText.length) {
      spans.add(TextSpan(text: remainingText.substring(lastMatchEnd)));
    }

    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: const Color(0xFFD1D1D1),
              fontFamily: GoogleFonts.newsreader().fontFamily,
              fontSize: 18,
            ),
        children: [
          WidgetSpan(
            child: Container(
              padding: const EdgeInsets.only(right: 8, bottom: 0, top: 4),
              child: Text(
                firstLetter,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textLight,
                  height: 0.8,
                ),
              ),
            ),
          ),
          ...spans,
        ],
      ),
    );
  }

  Widget _buildInfoBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryTeal.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.lightbulb, color: AppTheme.primaryTeal, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Key Takeaway",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Regular monitoring and early detection are the most effective ways to prevent pest infestations in your crops.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textMediumEmphasis,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingFooter(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryDarkBackground.withValues(alpha: 0.0),
              AppTheme.primaryDarkBackground.withValues(alpha: 0.8),
              AppTheme.primaryDarkBackground,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SelectCropScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.scanLine, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Start AI Diagnosis",
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
