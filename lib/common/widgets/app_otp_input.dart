import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';

/// Highly customizable OTP boxes built on a hidden TextField matching the design specs.
class AppOtpInput extends StatefulWidget {
  final int length;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool enabled;
  final bool autofocus;

  // Layout
  final double gap;
  final double height;
  final double radius;

  // Colors
  final Color? filledColor;
  final Color? focusedColor;
  final Color? emptyColor;
  final Color? textColor;
  final Color? cursorColor;

  const AppOtpInput({
    super.key,
    this.length = 6,
    this.controller,
    this.focusNode,
    this.onCompleted,
    this.onChanged,
    this.errorText,
    this.enabled = true,
    this.autofocus = false,
    this.gap = 12,
    this.height = 64,
    this.radius = 8,
    this.filledColor,
    this.focusedColor,
    this.emptyColor,
    this.textColor,
    this.cursorColor,
  });

  @override
  State<AppOtpInput> createState() => _AppOtpInputState();
}

class _AppOtpInputState extends State<AppOtpInput>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final bool _ownsController;
  late final bool _ownsFocusNode;
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _ownsFocusNode = widget.focusNode == null;
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _controller.addListener(_refresh);
    _focusNode.addListener(_onFocusChange);
    _onFocusChange();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _blink.repeat(reverse: true);
    } else {
      _blink.stop();
    }
    _refresh();
  }

  void _handleChanged(String value) {
    widget.onChanged?.call(value);
    if (value.length == widget.length) widget.onCompleted?.call(value);
  }

  void _moveCaretToEnd() {
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _focusNode.removeListener(_onFocusChange);
    _blink.dispose();
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final filledBg = widget.filledColor ?? const Color(0xFF1E293B);
    final focusedBg = widget.focusedColor ?? const Color(0xFF334155);
    final emptyBg = widget.emptyColor ?? const Color(0xFF0F172A);
    final numColor = widget.textColor ?? const Color(0xFFE2E8F0);
    final cursorColor = widget.cursorColor ?? const Color(0xFF94A3B8);
    final hasError = widget.errorText != null;

    final text = _controller.text;
    final hasFocus = _focusNode.hasFocus && widget.enabled;

    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth =
            ((constraints.maxWidth - widget.gap * (widget.length - 1)) /
                    widget.length)
                .clamp(44.0, 56.0);

        Widget box(int i) {
          final hasChar = i < text.length;
          final isActive = hasFocus && i == text.length;

          final bg = isActive ? focusedBg : (hasChar ? filledBg : emptyBg);
          final Color borderColor = hasError
              ? scheme.error
              : (isActive
                    ? scheme.primary
                    : AppColors.darkOnSurface.withAlpha(AppAlphas.badgeFill));

          Widget content;
          if (hasChar) {
            content = Text(
              text[i],
              style: theme.textTheme.headlineMedium?.copyWith(
                color: numColor,
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            );
          } else if (isActive) {
            content = FadeTransition(
              opacity: _blink,
              child: Container(width: 2.5, height: 26, color: cursorColor),
            );
          } else {
            content = Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF475569),
                shape: BoxShape.circle,
              ),
            );
          }

          return Container(
            width: boxWidth,
            height: widget.height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(widget.radius),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: content,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              color: Colors.transparent,
              child: SizedBox(
                height: widget.height,
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < widget.length; i++) ...[
                          if (i > 0) SizedBox(width: widget.gap),
                          box(i),
                        ],
                      ],
                    ),
                    Positioned.fill(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled: widget.enabled,
                        autofocus: widget.autofocus,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(widget.length),
                        ],
                        onChanged: _handleChanged,
                        onTap: _moveCaretToEnd,
                        expands: true,
                        maxLines: null,
                        minLines: null,
                        showCursor: false,
                        enableInteractiveSelection: false,
                        cursorColor: Colors.transparent,
                        style: const TextStyle(color: Colors.transparent),
                        decoration: const InputDecoration(
                          isCollapsed: true,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          counterText: '',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: AppSizes.sm),
              Text(
                widget.errorText!,
                style: theme.textTheme.bodySmall!.copyWith(color: scheme.error),
              ),
            ],
          ],
        );
      },
    );
  }
}
