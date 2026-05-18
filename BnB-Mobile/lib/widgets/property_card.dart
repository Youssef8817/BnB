import 'package:b_and_b/models/property.dart';
import 'package:b_and_b/screens/property_detail_screen.dart';
import 'package:b_and_b/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  const PropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PropertyDetailScreen(property: property),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  SizedBox(
                    height: 180,
                    child: property.images.isNotEmpty
                        ? Image.network(
                            property.images.first.fullUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => _placeholder(),
                            loadingBuilder: (_, child, progress) =>
                                progress == null ? child : _placeholder(),
                          )
                        : _placeholder(),
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 72,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xCC060B18)],
                        ),
                      ),
                    ),
                  ),
                  // Status badge in corner
                  Positioned(
                    top: 12,
                    right: 12,
                    child: StatusBadge(status: property.status),
                  ),
                  // City chip bottom-left
                  if (property.city.isNotEmpty)
                    Positioned(
                      bottom: 10,
                      left: 12,
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 11,
                            color: AppColors.textSecondary.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            property.city,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.h4.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    property.formattedPrice,
                    style: AppText.price.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Stat(icon: Icons.bed_rounded, label: '${property.rooms} rooms'),
                      const SizedBox(width: 14),
                      _Stat(
                        icon: Icons.square_foot_rounded,
                        label: '${property.areaMq.toStringAsFixed(0)}m²',
                      ),
                      if (property.location.isNotEmpty) ...[
                        const SizedBox(width: 14),
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: AppColors.textMuted.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  property.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.bodySmall.copyWith(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradientCard,
        ),
        child: Center(
          child: Icon(
            Icons.home_work_outlined,
            color: AppColors.accent.withValues(alpha: 0.20),
            size: 48,
          ),
        ),
      );
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Stat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted.withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        Text(label, style: AppText.bodySmall.copyWith(fontSize: 11)),
      ],
    );
  }
}
