import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/language_service.dart';
import 'camera_interface.dart';

class SelectCropScreen extends StatefulWidget {
  const SelectCropScreen({super.key});

  @override
  State<SelectCropScreen> createState() => _SelectCropScreenState();
}

class _SelectCropScreenState extends State<SelectCropScreen> {
  String? _selectedCrop;

  final List<Map<String, String>> _crops = [
    {
      'id': 'rice',
      'name': 'Rice',
      'name_id': 'Padi',
      'image': 'assets/images/rice_field.jpg',
    },
    {
      'id': 'tomato',
      'name': 'Tomato',
      'name_id': 'Tomat',
      'image': 'assets/images/fresh_tomatoes.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final langService = Provider.of<LanguageService>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          langService.translate('Select Crop', 'Pilih Tanaman'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              langService.translate('Which crop would you like to diagnose?', 'Tanaman mana yang ingin Anda diagnosa?'),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: _crops.length,
                itemBuilder: (context, index) {
                  final crop = _crops[index];
                  final isSelected = _selectedCrop == crop['id'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCrop = crop['id'];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurfaceDark,
                        borderRadius: BorderRadius.circular(24),
                        border: isSelected
                            ? Border.all(color: AppTheme.primaryTeal, width: 2)
                            : Border.all(color: Colors.transparent, width: 2),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 3,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                                  child: Image.asset(
                                    crop['image']!,
                                    fit: BoxFit.cover,
                                    cacheWidth: 400,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    langService.isIndonesian ? crop['name_id']! : crop['name']!,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (isSelected)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryTeal,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedCrop != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CameraInterface(selectedCrop: _selectedCrop!),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedCrop != null 
                      ? AppTheme.primaryTeal 
                      : AppTheme.cardSurfaceDark,
                  foregroundColor: _selectedCrop != null 
                      ? AppTheme.textLight 
                      : AppTheme.textMediumEmphasis,
                ),
                child: Text(langService.translate('Start Diagnosis', 'Mulai Diagnosa')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}