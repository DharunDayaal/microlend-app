import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/l10n/locale_controller.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';

Future<void> showLanguageSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _LanguageSheet(),
    );

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;

    // language names stay in their own language
    final options = [
      (const Locale('en'), l.languageEnglish),
      (const Locale('ta'), l.languageTamil),
    ];

    return Consumer(
      builder: (context, ref, _) {
        final current = ref.watch(localeProvider).languageCode;
        return Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.languageTitle, style: text.headlineSmall),
              const SizedBox(height: 4),
              Text(
                l.languageSubtitle,
                style: text.labelMedium?.copyWith(
                  color: AppColors.darkOnSurfaceMuted,
                ),
              ),
              AppGap.h12,
              for (final (locale, name) in options)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(name),
                  trailing: current == locale.languageCode
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.stepCurrentLabel,
                        )
                      : null,
                  onTap: () async {
                    await ref.read(localeProvider.notifier).setLocale(locale);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Header button showing the current language ("EN" / "த"); opens
/// [showLanguageSheet].
class LanguageButton extends ConsumerWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(localeProvider).languageCode;
    final label = code == 'ta' ? 'த' : 'EN';

    return Tooltip(
      message: AppLocalizations.of(context).languageTitle,
      child: Semantics(
        button: true,
        label: AppLocalizations.of(context).languageTitle,
        excludeSemantics: true,
        child: InkWell(
          onTap: () => showLanguageSheet(context),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm + 2),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.translate_rounded,
                  size: 16,
                  color: AppColors.stepCurrentLabel,
                ),
                const SizedBox(width: AppSizes.xs),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.darkOnSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
