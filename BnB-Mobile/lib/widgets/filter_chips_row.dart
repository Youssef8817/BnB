import 'package:flutter/material.dart';

class FilterChipsRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final void Function(String) onSelected;

  const FilterChipsRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: options.map((option) {
          final isActive = selected == option;
          return GestureDetector(
            onTap: () => onSelected(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: isActive
                    ? const LinearGradient(
                        colors: [Color(0xFFA078FF), Color(0xFF00A2E6)],
                      )
                    : null,
                color: isActive
                    ? null
                    : Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: isActive
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.10),
                ),
                boxShadow: isActive
                    ? const [
                        BoxShadow(
                          color: Color(0x33A078FF),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? const Color(0xFF3C0091)
                      : const Color(0xFFCBC3D7),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
