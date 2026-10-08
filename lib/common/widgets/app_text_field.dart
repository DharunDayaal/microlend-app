import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
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
  final Widget? suffixIcon;
  final bool showValidIcon;
  final bool isPassword;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final IconData? labelIcon;
  final bool? isRequired;
  final bool? showHeader;

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
    this.focusNode,
    this.labelIcon,
    this.isRequired,
    this.showHeader = true,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;
  bool _hasFocus = false;
  bool _hasText = false;

  late bool _obscure = widget.isPassword;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    final initial = widget.controller?.text ?? '';
    _isValid = _check(initial);
    _hasText = initial.isNotEmpty;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus != _hasFocus) {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    }
  }

  bool _check(String value) {
    if (!widget.showValidIcon || value.trim().isEmpty) return false;
    return widget.validator?.call(value) == null;
  }

  void _handleChanged(String value) {
    final valid = _check(value);
    final hasText = value.isNotEmpty;
    if (valid != _isValid || hasText != _hasText) {
      setState(() {
        _isValid = valid;
        _hasText = hasText;
      });
    }
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
        if (widget.showHeader!) ...[
          SizedBox(
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.labelIcon != null) ...[
                  Icon(
                    widget.labelIcon,
                    color: AppColors.darkOnSurface,
                    size: AppSizes.lg,
                  ),
                  AppGap.w8,
                ],
                Text(
                  TextFormatter.titleCase(widget.label),
                  style: text.labelLarge,
                ),
                if (widget.isRequired != null && widget.isRequired!) ...[
                  const Spacer(),
                  Text(
                    "*Required",
                    style: text.labelMedium?.copyWith(
                      color: AppColors.progressWarning,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],

        AppGap.h8,
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
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
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon),
            prefix: (widget.prefixText != null && (_hasFocus || _hasText))
                ? Padding(
                    padding: const EdgeInsets.only(right: AppSizes.sm),
                    child: Text(widget.prefixText!, style: text.bodyLarge),
                  )
                : null,
            suffixIcon: _suffix(),
          ),
        ),
      ],
    );
  }
}
