import 'package:flutter/material.dart';
import 'package:app_qinspecting/widgets/board_image.dart';

class PhotoSection extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final VoidCallback onCapturePhoto;

  const PhotoSection({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.onCapturePhoto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            BoardImage(url: imageUrl),
            Positioned(
              right: 15,
              bottom: 10,
              child: IconButton(
                onPressed: onCapturePhoto,
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 45,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
