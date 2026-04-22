import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

class DualCurrencyText extends StatelessWidget {
  final double usd;
  final double sos;
  final bool showBoth;
  final bool large;
  final CrossAxisAlignment alignment;

  const DualCurrencyText({
    super.key,
    required this.usd,
    required this.sos,
    this.showBoth = true,
    this.large = false,
    this.alignment = CrossAxisAlignment.start,
  });

  String _formatUsd(double amount) => '\$${amount.toStringAsFixed(2)}';
  String _formatSos(double amount) => amount >= 1000 ? '${(amount / 1000).toStringAsFixed(1)}K SOS' : '${amount.toStringAsFixed(0)} SOS';

  @override
  Widget build(BuildContext context) {
    if (!showBoth) {
      return Text(_formatUsd(usd), style: (large ? T.sectionHeader : T.body).copyWith(fontWeight: FontWeight.w700, color: C.accent));
    }

    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_formatUsd(usd), style: large ? T.sectionHeader.copyWith(color: C.accent) : T.body.copyWith(fontWeight: FontWeight.w700, color: C.accent)),
        Text(_formatSos(sos), style: T.caption),
      ],
    );
  }
}

class CurrencyFormatter {
  static String formatUsd(double amount) {
    if (amount >= 1000000) return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(1)}K';
    return '\$${amount.toStringAsFixed(2)}';
  }

  static String formatSos(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M SOS';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K SOS';
    return '${amount.toStringAsFixed(0)} SOS';
  }

  static String formatSosCompact(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }
}

class ExchangeRate {
  static const double usdToSos = 2700.0;
  static double sosToUsd(double sos) => sos / usdToSos;
  static double usdToSosUsd(double usd) => usd * usdToSos;
}
