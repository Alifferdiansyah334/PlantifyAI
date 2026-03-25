import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import '../models/article.dart';
import '../services/article_service.dart';
import '../theme/app_theme.dart';

class ArticleManagementScreen extends StatelessWidget {
  const ArticleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final articleService = Provider.of<ArticleService>(context);
    final allArticles = articleService.allArticles;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Manage Articles'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: allArticles.length,
        itemBuilder: (context, index) {
          final article = allArticles[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardSurfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildLeadingImage(article),
              ),
              title: Text(
                article.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.category, 
                    style: TextStyle(color: AppTheme.primaryTeal, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'By ${article.authorName}', 
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    article.authorRole, 
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 9),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.edit2, color: AppTheme.primaryTeal, size: 18),
                    onPressed: () => _showArticleForm(context, article: article),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, color: AppTheme.redBadgeError, size: 18),
                    onPressed: () => _confirmDelete(context, articleService, article),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryTeal,
        onPressed: () => _showArticleForm(context),
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildLeadingImage(Article article) {
    if (article.imageUrl.startsWith('assets/')) {
      return Image.asset(
        article.imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        File(article.imageUrl),
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.white10,
          width: 50,
          height: 50,
          child: const Icon(LucideIcons.image, color: Colors.white24, size: 20),
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context, ArticleService service, Article article) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardSurfaceDark,
        title: const Text('Delete Article?', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete "${article.title}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              service.deleteArticle(article.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.redBadgeError)),
          ),
        ],
      ),
    );
  }

  void _showArticleForm(BuildContext context, {Article? article}) {
    final articleService = Provider.of<ArticleService>(context, listen: false);
    
    final titleController = TextEditingController(text: article?.title);
    final summaryController = TextEditingController(text: article?.summary);
    final contentController = TextEditingController(text: article?.content);
    final authorController = TextEditingController(text: article?.authorName);
    final roleController = TextEditingController(text: article?.authorRole);
    
    String? selectedCategory = article?.category;
    String? selectedImagePath = article?.imageUrl;
    String? selectedAuthorImagePath = article?.authorImageUrl;
    bool isFeatured = article?.isFeatured ?? false;

    final List<String> categories = ArticleService.categories;

    // Ensure initial selectedCategory is in the list or null
    if (selectedCategory != null && !categories.contains(selectedCategory)) {
        selectedCategory = null; 
    }


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardSurfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      article == null ? 'Create Article' : 'Edit Article',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: Colors.white38),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Article Image Picker
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setModalState(() {
                        selectedImagePath = image.path;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: selectedImagePath == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.imagePlus, color: AppTheme.primaryTeal, size: 32),
                              SizedBox(height: 8),
                              Text('Tap to select article image', style: TextStyle(color: Colors.white38, fontSize: 12)),
                            ],
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: selectedImagePath!.startsWith('assets/')
                                    ? Image.asset(selectedImagePath!, fit: BoxFit.cover)
                                    : Image.file(File(selectedImagePath!), fit: BoxFit.cover),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(LucideIcons.refreshCw, color: Colors.white, size: 28),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                 // Author Image Picker
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setModalState(() {
                            selectedAuthorImagePath = image.path;
                          });
                        }
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: selectedAuthorImagePath == null
                            ? const Icon(LucideIcons.userPlus, color: AppTheme.primaryTeal, size: 24)
                            : ClipOval(
                                child: selectedAuthorImagePath!.startsWith('assets/')
                                    ? Image.asset(selectedAuthorImagePath!, fit: BoxFit.cover)
                                    : Image.file(File(selectedAuthorImagePath!), fit: BoxFit.cover),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text('Author Photo', style: TextStyle(color: Colors.white, fontSize: 14)),
                           Text('Tap to select', style: TextStyle(color: Colors.white38, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                _buildTextField(titleController, 'Title (e.g. How to grow Rice)'),
                
                // Category Dropdown
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    dropdownColor: AppTheme.cardSurfaceDark,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primaryTeal),
                      ),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.2),
                    ),
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setModalState(() {
                        selectedCategory = newValue;
                      });
                    },
                  ),
                ),

                _buildTextField(authorController, 'Author Name (e.g. Dr. John Doe)', maxLength: 25),
                _buildTextField(roleController, 'Author Role (e.g. Senior Botanist)', maxLength: 35),
                _buildTextField(summaryController, 'Short Summary', maxLines: 2),
                _buildTextField(contentController, 'Article Content', maxLines: 6),
                
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Mark as Featured', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text('Will appear in the top carousel', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  value: isFeatured,
                  activeThumbColor: AppTheme.primaryTeal,
                  onChanged: (val) => setModalState(() => isFeatured = val),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (titleController.text.isEmpty || selectedImagePath == null || selectedCategory == null) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Please provide title, category and image')),
                         );
                         return;
                      }

                      final newArticle = Article(
                        id: article?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text,
                        category: selectedCategory!,
                        imageUrl: selectedImagePath!,
                        date: article?.date ?? 'Dec 30, 2025',
                        readTime: article?.readTime ?? '5 min read',
                        summary: summaryController.text,
                        content: contentController.text,
                        authorName: authorController.text.isEmpty ? 'Admin' : authorController.text,
                        authorRole: roleController.text.isEmpty ? 'Staff' : roleController.text,
                        authorImageUrl: selectedAuthorImagePath ?? 'assets/images/profile_pic.png',
                        isFeatured: isFeatured,
                      );

                      if (article == null) {
                        articleService.addArticle(newArticle);
                      } else {
                        articleService.updateArticle(newArticle);
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Save Article', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, int? maxLength}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
          alignLabelWithHint: true,
          counterStyle: const TextStyle(color: Colors.white38, fontSize: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primaryTeal),
          ),
          filled: true,
          fillColor: Colors.black.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
