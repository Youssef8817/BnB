// lib/widgets/property_card.dart
import 'package:b_and_b/models/property.dart';
import 'package:b_and_b/screens/property_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PropertyCard extends StatelessWidget {
  final Property property;

  const PropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PropertyDetailScreen(property: property),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hasBoundedHeight = constraints.hasBoundedHeight;
            final imageHeight = hasBoundedHeight
                ? (constraints.maxHeight * 0.62).clamp(120.0, 220.0)
                : 160.0;

            final image = SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: property.images.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: property.images.first.fullUrl,
                      fit: BoxFit.cover,
                      placeholder: (c, _) => Container(color: Colors.grey[200]),
                      errorWidget: (c, _, __) =>
                          Container(color: Colors.grey[200]),
                    )
                  : Container(color: Colors.grey[200]),
            );

            final details = Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    property.formattedPrice,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.green),
                  ),
                  const SizedBox(height: 4),
                  _MetaRow(property: property),
                ],
              ),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: hasBoundedHeight
                  ? [image, Expanded(child: details)]
                  : [image, details],
            );
          },
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final Property property;
  const _MetaRow({required this.property});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(property.city,
              style: const TextStyle(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
        Text('${property.rooms} rooms', style: const TextStyle(fontSize: 11)),
        Text('${property.areaMq.toStringAsFixed(0)}m²',
            style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
