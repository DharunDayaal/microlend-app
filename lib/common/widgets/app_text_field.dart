import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';

/// Label above, field below. Everything else (border, fill, focus) comes
/// from inputDecorationTheme.
class AppTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? hint;
  final String? prefixText;
  final bool isPassword;
  final bool enabled;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
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
    this.isPassword = false,
    this.enabled = true,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.isPassword;

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
          onChanged: widget.onChanged,
          style: text.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixText: widget.prefixText,
            prefixIcon: Icon(widget.prefixIcon),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : Icon(widget.suffixIcon),
          ),
        ),
      ],
    );
  }
}
