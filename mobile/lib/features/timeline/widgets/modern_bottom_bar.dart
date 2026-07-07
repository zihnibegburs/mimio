import 'package:flutter/material.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/core/widgets/liquid_glass.dart';

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

    return LiquidGlass(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      borderRadius: BorderRadius.circular(32),
      blur: true,
      blurSigma: LiquidGlassTokens.blurSigmaChrome,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
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
            color: selected
                ? MimioColors.primary.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(22),
            border: selected
                ? Border.all(color: MimioColors.primary.withValues(alpha: 0.25))
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                size: 22,
                color: selected ? MimioColors.primary : context.palette.textSecondary,
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? MimioColors.primary : context.palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
