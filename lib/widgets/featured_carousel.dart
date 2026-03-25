import 'dart:async';
import 'package:flutter/material.dart';
import '../models/article.dart';
import '../theme/app_theme.dart';
import 'featured_article.dart';
import '../screens/article_detail_screen.dart';

class FeaturedCarousel extends StatefulWidget {
  final List<Article> articles;

  const FeaturedCarousel({super.key, required this.articles});

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    if (widget.articles.length > 1) {
      _startAutoScroll();
    }
  }

  @override
  void didUpdateWidget(FeaturedCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart or stop timer based on new article count
    _timer?.cancel();
    if (widget.articles.length > 1) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (!mounted) return;
      
      if (_currentPage < widget.articles.length - 1) {
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

  @override
  Widget build(BuildContext context) {
    if (widget.articles.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.articles.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final article = widget.articles[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FeaturedArticle(
                  article: article,
                  heroTag: 'library_featured_${article.id}',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleDetailScreen(
                          article: article,
                          heroTag: 'library_featured_${article.id}',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        if (widget.articles.length > 1) ...[
          const SizedBox(height: 12),
                    // Page Indicators
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.articles.length,
                          (index) {
                            // If there are too many items, we could simplify this, 
                            // but for now we'll show all dots with smaller size if needed.
                            double size = widget.articles.length > 10 ? 4 : 8;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _currentPage == index ? size * 2 : size,
                              height: size,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(size / 2),
                                color: _currentPage == index
                                    ? AppTheme.primaryTeal
                                    : AppTheme.textMediumEmphasis.withValues(alpha: 0.2),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }
          }
          