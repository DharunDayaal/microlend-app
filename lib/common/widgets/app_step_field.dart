import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';

/// A number field with - and + buttons. Steps by [step], stays inside
/// [min]..[max] and keeps one decimal place.
class AppStepField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String suffix;
  final double min;
  final double max;
  final double step;
  final String? error;
  final bool enabled;

  /// Called after the +/- buttons or typing change the text.
  final VoidCallback onChanged;

  const AppStepField({
    super.key,
    required this.label,
    required this.controller,
    required this.min,
    required this.max,
    required this.onChanged,
    this.suffix = '',
    this.step = 0.5,
    this.error,
    this.enabled = true,
  });

  static String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  void _bump(double delta) {
    final now = double.tryParse(controller.text.trim()) ?? min;
    final v = (now + delta).clamp(min, max).toDouble();
    controller.text = _fmt(double.parse(v.toStringAsFixed(1)));
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: IconButton.filledTonal(
            tooltip: 'Decrease $label',
            onPressed: enabled ? () => _bump(-step) : null,
            icon: const Icon(Icons.remove),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d{0,4}\.?\d{0,2}')),
            ],
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              labelText: label,
              suffixText: suffix.isEmpty ? null : suffix,
              errorText: error,
              errorMaxLines: 2,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: IconButton.filledTonal(
            tooltip: 'Increase $label',
            onPressed: enabled ? () => _bump(step) : null,
            icon: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}