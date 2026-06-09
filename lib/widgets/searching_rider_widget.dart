import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_theme.dart';

class SearchingRiderWidget extends StatefulWidget {
  const SearchingRiderWidget({super.key});

  @override
  State<SearchingRiderWidget> createState() => _SearchingRiderWidgetState();
}

class _SearchingRiderWidgetState extends State<SearchingRiderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    width: 80 + (_controller.value * 40),
                    height: 80 + (_controller.value * 40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary
                          .withValues(alpha: (1.0 - _controller.value) * 0.3),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    width: 60 + (_controller.value * 20),
                    height: 60 + (_controller.value * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary
                          .withValues(alpha: (1.0 - _controller.value) * 0.6),
                    ),
                  );
                },
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryAccent.withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Iconsax.radar5,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Searching for Delivery Partner...',
            style: AppTextStyles.cardTitle.copyWith(
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we connect you with a rider nearby.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
