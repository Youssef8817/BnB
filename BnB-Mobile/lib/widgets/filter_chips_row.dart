// lib/widgets/filter_chips_row.dart
import 'package:flutter/material.dart';

class FilterChipsRow extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final Function(String?) onSelected;

  const FilterChipsRow({
    Key? key,
    required this.options,
    required this.selected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          final bool isSelected = selected == option;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (bool selected) {
                onSelected(selected ? option : null);
              },
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              selectedColor: Colors.blue,
              checkmarkColor: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }
}