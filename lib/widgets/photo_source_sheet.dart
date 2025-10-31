import 'package:flutter/material.dart';
import 'package:app_qinspecting/ui/app_theme.dart';
import 'package:app_qinspecting/widgets/profile/photo_option_button.dart';

class PhotoSourceSheet extends StatelessWidget {
  final String title;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const PhotoSourceSheet({
    Key? key,
    required this.title,
    required this.onCamera,
    required this.onGallery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).viewPadding.bottom +
            20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreen,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: PhotoOptionButton(
                  icon: Icons.camera_alt,
                  label: 'Cámara',
                  onTap: onCamera,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PhotoOptionButton(
                  icon: Icons.photo_library,
                  label: 'Galería',
                  onTap: onGallery,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
