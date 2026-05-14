import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../services/api_url.dart';

class AvailableMedicinePreviewCard extends StatelessWidget {
  final String imageUrl;

  const AvailableMedicinePreviewCard({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  "${ApiUrl.baseUrl}/$imageUrl",
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Iconsax.image,
                    color: Colors.white54,
                    size: 100,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Iconsax.close_circle, color: Colors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
