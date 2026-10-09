import 'package:flutter/material.dart';
import '../../core/theme/meter_theme_colors.dart';

/// Industrial Revenue Performance Tile
/// Deep matte surface, 1px hardware frame, monospaced tabular figures.
class RevenueTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isCurrency;
  final IconData? icon;

  const RevenueTile({
    super.key,
    required this.label,
    required this.value,
    this.isCurrency = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.meterColors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 4),
                Icon(
                  icon,
                  size: 16,
                  color: isCurrency ? const Color(0xFFFFB300) : const Color(0xFF2979FF),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'monospace', // Tabular non-jumping figures
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: isCurrency ? const Color(0xFFFFB300) : colors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
