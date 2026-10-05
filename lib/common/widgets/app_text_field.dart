import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? hint;
  final String? prefixText;
  final IconData? prefixIcon;
  final Widget? suffixIcon; // custom suffix (ignored for password fields)
  final bool showValidIcon; // green tick when the value passes the validator
  final bool isPassword;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.hint,
    this.prefixText,
    this.prefixIcon,
    this.suffixIcon,
    this.showValidIcon = false,
    this.isPassword = false,
    this.enabled = true,
    this.onChanged,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.isPassword;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _isValid = _check(widget.controller?.text ?? '');
  }

  bool _check(String value) {
    if (!widget.showValidIcon || value.trim().isEmpty) return false;
    return widget.validator?.call(value) == null;
  }

  void _handleChanged(String value) {
    final valid = _check(value);
    if (valid != _isValid) setState(() => _isValid = valid);
    widget.onChanged?.call(value);
  }

  Widget? _suffix() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
        onPressed: () => setState(() => _obscure = !_obscure),
      );
    }
    if (widget.showValidIcon && _isValid) {
      return const Icon(Icons.check_circle, color: AppColors.success);
    }
    return widget.suffixIcon;
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(TextFormatter.label(widget.label), style: text.labelMedium),
        AppGap.h8,
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          obscureText: _obscure,
          enabled: widget.enabled,
          onChanged: _handleChanged,
          style: text.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixText: widget.prefixText,
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon),
            suffixIcon: _suffix(),
          ),
        ),
      ],
    );
  }
}
