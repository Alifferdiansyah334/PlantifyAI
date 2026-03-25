import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../services/language_service.dart';
import 'article_management_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langService = Provider.of<LanguageService>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(langService.translate('Settings', 'Pengaturan')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader(context, langService.translate('Localization', 'Lokalisasi')),
          _buildSettingTile(
            context,
            title: langService.translate('Language', 'Bahasa'),
            subtitle: langService.translate('Choose your preferred language', 'Pilih bahasa yang Anda gunakan'),
            icon: LucideIcons.languages,
            trailing: DropdownButton<String>(
              value: langService.locale.languageCode,
              dropdownColor: AppTheme.cardSurfaceDark,
              underline: const SizedBox(),
              icon: const Icon(LucideIcons.chevronDown, size: 16, color: Colors.white38),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English', style: TextStyle(color: Colors.white, fontSize: 14))),
                DropdownMenuItem(value: 'id', child: Text('Indonesia', style: TextStyle(color: Colors.white, fontSize: 14))),
              ],
              onChanged: (value) {
                if (value != null) langService.setLanguage(value);
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, langService.translate('Administration', 'Administrasi')),
          _buildSettingTile(
            context,
            title: langService.translate('Article Management', 'Manajemen Artikel'),
            subtitle: langService.translate('Create, edit, or delete articles', 'Buat, edit, atau hapus artikel'),
            icon: LucideIcons.fileEdit,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ArticleManagementScreen()),
              );
            },
          ),
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Text(
                  'Plantify AI',
                  style: TextStyle(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.primaryTeal,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardSurfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryTeal, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)) : null,
        trailing: trailing ?? (onTap != null ? const Icon(LucideIcons.chevronRight, color: Colors.white24, size: 18) : null),
      ),
    );
  }
}
