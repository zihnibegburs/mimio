import 'package:flutter/material.dart';
import 'package:mimio/core/theme/mimio_theme.dart';

class ModernNavItem {
  const ModernNavItem({required this.icon, required this.selectedIcon, required this.label});

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class ModernBottomBar extends StatelessWidget {
  const ModernBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.items,
    this.centerGap = 56,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<ModernNavItem> items;
  final double centerGap;

  @override
  Widget build(BuildContext context) {
    final leftCount = items.length ~/ 2;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8E8F0)),
        boxShadow: [
          BoxShadow(
            color: MimioColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < leftCount; i++)
            Expanded(child: _NavButton(item: items[i], selected: selectedIndex == i, onTap: () => onSelected(i))),
          SizedBox(width: centerGap),
          for (var i = leftCount; i < items.length; i++)
            Expanded(child: _NavButton(item: items[i], selected: selectedIndex == i, onTap: () => onSelected(i))),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected, required this.onTap});

  final ModernNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? MimioColors.primary.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                size: 22,
                color: selected ? MimioColors.primary : MimioColors.textSecondary,
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? MimioColors.primary : MimioColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
