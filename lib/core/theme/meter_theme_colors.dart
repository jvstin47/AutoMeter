import 'package:flutter/material.dart';

@immutable
class MeterThemeColors extends ThemeExtension<MeterThemeColors> {
  final Color bg;
  final Color surface;
  final Color card;
  final Color cardBorder;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color meterAmber;
  final Color meterAmberGlow;
  final Color meterGreen;
  final Color meterGreenGlow;
  final Color meterCyan;
  final Color meterRed;

  const MeterThemeColors({
    required this.bg,
    required this.surface,
    required this.card,
    required this.cardBorder,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.meterAmber,
    required this.meterAmberGlow,
    required this.meterGreen,
    required this.meterGreenGlow,
    required this.meterCyan,
    required this.meterRed,
  });

  // Predefined themes
  static const amoled = MeterThemeColors(
    bg: Color(0xFF000000), // Pure OLED pitch black
    surface: Color(0xFF0D0D0F),
    card: Color(0xFF141417),
    cardBorder: Color(0xFF26262B),
    divider: Color(0xFF1C1C20),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA1A1AA),
    textMuted: Color(0xFF71717A),
    meterAmber: Color(0xFFFFB020),
    meterAmberGlow: Color(0x33FFB020),
    meterGreen: Color(0xFF10B981),
    meterGreenGlow: Color(0x3310B981),
    meterCyan: Color(0xFF06B6D4),
    meterRed: Color(0xFFEF4444),
  );

  static const slate = MeterThemeColors(
    bg: Color(0xFF0A0C10),
    surface: Color(0xFF131722),
    card: Color(0xFF1A202C),
    cardBorder: Color(0xFF2D3748),
    divider: Color(0xFF242C38),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    meterAmber: Color(0xFFFFB020),
    meterAmberGlow: Color(0x33FFB020),
    meterGreen: Color(0xFF10B981),
    meterGreenGlow: Color(0x3310B981),
    meterCyan: Color(0xFF06B6D4),
    meterRed: Color(0xFFEF4444),
  );

  static const light = MeterThemeColors(
    bg: Color(0xFFF4F6F9),
    surface: Color(0xFFFFFFFF),
    card: Color(0xFFF8FAFC),
    cardBorder: Color(0xFFE2E8F0),
    divider: Color(0xFFCBD5E1),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF64748B),
    meterAmber: Color(0xFFD97706),
    meterAmberGlow: Color(0x22D97706),
    meterGreen: Color(0xFF059669),
    meterGreenGlow: Color(0x22059669),
    meterCyan: Color(0xFF0284C7),
    meterRed: Color(0xFFDC2626),
  );

  @override
  MeterThemeColors copyWith({
    Color? bg,
    Color? surface,
    Color? card,
    Color? cardBorder,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? meterAmber,
    Color? meterAmberGlow,
    Color? meterGreen,
    Color? meterGreenGlow,
    Color? meterCyan,
    Color? meterRed,
  }) {
    return MeterThemeColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      cardBorder: cardBorder ?? this.cardBorder,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      meterAmber: meterAmber ?? this.meterAmber,
      meterAmberGlow: meterAmberGlow ?? this.meterAmberGlow,
      meterGreen: meterGreen ?? this.meterGreen,
      meterGreenGlow: meterGreenGlow ?? this.meterGreenGlow,
      meterCyan: meterCyan ?? this.meterCyan,
      meterRed: meterRed ?? this.meterRed,
    );
  }

  @override
  MeterThemeColors lerp(ThemeExtension<MeterThemeColors>? other, double t) {
    if (other is! MeterThemeColors) return this;
    return MeterThemeColors(
      bg: Color.lerp(bg, other.bg, t) ?? bg,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      card: Color.lerp(card, other.card, t) ?? card,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t) ?? cardBorder,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      meterAmber: Color.lerp(meterAmber, other.meterAmber, t) ?? meterAmber,
      meterAmberGlow: Color.lerp(meterAmberGlow, other.meterAmberGlow, t) ?? meterAmberGlow,
      meterGreen: Color.lerp(meterGreen, other.meterGreen, t) ?? meterGreen,
      meterGreenGlow: Color.lerp(meterGreenGlow, other.meterGreenGlow, t) ?? meterGreenGlow,
      meterCyan: Color.lerp(meterCyan, other.meterCyan, t) ?? meterCyan,
      meterRed: Color.lerp(meterRed, other.meterRed, t) ?? meterRed,
    );
  }
}

extension MeterThemeExtension on BuildContext {
  MeterThemeColors get meterColors =>
      Theme.of(this).extension<MeterThemeColors>() ?? MeterThemeColors.amoled;
}
