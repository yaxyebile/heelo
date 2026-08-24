import 'package:flutter/material.dart';
import '../constants/colors.dart';

class HakaboSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final bool showFilter;

  const HakaboSearchBar({
    super.key,
    this.hint = 'Search products, brands...',
    this.onChanged,
    this.onFilterTap,
    this.showFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.textSecondaryLight, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondaryLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showFilter) ...[
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 22),
            ),
          ),
        ],
      ],
    );
  }
}
