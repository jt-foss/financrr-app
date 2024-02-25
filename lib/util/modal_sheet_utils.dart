import 'dart:io';

import 'package:financrr_frontend/data/host_repository.dart';
import 'package:financrr_frontend/themes.dart';
import 'package:financrr_frontend/util/constants.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/util/text_utils.dart';
import 'package:financrr_frontend/widgets/animations/zoom_tap_animation.dart';
import 'package:financrr_frontend/widgets/custom_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/custom_button.dart';

class Modal {
  final String title;
  final bool showCloseButton;
  final Widget Function(BuildContext) child;

  const Modal._({required this.title, this.showCloseButton = true, required this.child});

  Future show(BuildContext context) {
    final FinancrrTheme financrrTheme = context.financrrTheme;
    final AppTextStyles textStyles = AppTextStyles.of(context);
    return showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        isDismissible: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        backgroundColor: financrrTheme.primaryBackgroundColor,
        builder: (ctx) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (showCloseButton)
                          ZoomTapAnimation(
                              onTap: () => Navigator.of(context).pop("Close"),
                              child: Icon(Icons.arrow_back, color: financrrTheme.primaryAccentColor)),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 20),
                          child: textStyles.titleMedium.text(title,
                              textAlign: TextAlign.center,
                              color: financrrTheme.primaryAccentColor,
                              fontWeightOverride: FontWeight.w700),
                        ),
                        const Spacer()
                      ],
                    ),
                  ),
                  child(context)
                ],
              ),
            ),
          );
        });
  }
}

class Modals {
  const Modals._();

  static Modal hostSelectModal() {
    return Modal._(
        title: 'Select Host',
        child: (context) => Column(children: [
              CustomButton.tertiary(
                  text: 'Financrr Cloud',
                  prefixIcon: Icons.wb_cloudy_outlined,
                  subText: (context) => 'We’ll do the work for you in exchange for a small monthly fee.',
                  onPressed: () => Navigator.of(context).pop("Close")),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: CustomButton.tertiary(
                    text: 'Selfhosted',
                    prefixIcon: Icons.language,
                    suffixIcon: Icons.open_in_new_rounded,
                    subText: (context) => 'Host your own financrr Instance! More Information on financrr.app/selfhost',
                    onPressed: () {
                      Navigator.of(context).pop("Close");
                      Modals.customHostEnterModal(TextEditingController()).show(context);
                    }),
              ),
            ]));
  }

  static Modal customHostEnterModal(TextEditingController controller) {
    return Modal._(
        title: 'Enter Custom Host',
        child: (context) {
          final AppLocalizations locale = context.locale;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextUtils.paddedTitle(context, title: locale.genericURL, topPadding: false),
            CustomTextField(controller: controller, prefixIcon: Icons.link, hintText: locale.genericURLEnter),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: CustomButton.primary(
                  text: 'Use Custom Host',
                  onPressed: () {
                    String url = controller.text;
                    if (!url.startsWith('https://') && !url.startsWith('http://')) {
                      controller.text = 'https://$url';
                      return;
                    }
                    HostService.setHostPreferences(url).then((prefs) {
                      Navigator.of(context).pop("Close");
                      GlobalKeys.loginPage.currentState?.checkHostUrl(prefs);
                    });
                  }),
            ),
          ]);
        });
  }
}

class ModalSheetOption {
  final String label;
  final Widget? child;
  final Color? primary, secondary;
  final Function()? onTap;

  /// The default constructor - used for basic options
  const ModalSheetOption({required this.label, this.child, this.onTap, this.primary}) : secondary = Colors.transparent;

  /// Uses red text - used for actions that cannot be reverted
  ModalSheetOption.remove(BuildContext context, {required this.label, this.child, this.onTap})
      : primary = context.financrrTheme.primaryAccentColor,
        secondary = context.financrrTheme.secondaryBackgroundColor;
}

class ModalSheetUtils {
  const ModalSheetUtils._();

  static Future show(BuildContext context, {required List<ModalSheetOption> options, String? title, String? message}) {
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      return showCupertinoModalPopup(
          context: context, builder: (context) => _cupertino(context, options: options, title: title, message: message));
    }
    return showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => _other(context, options: options, title: title, message: message));
  }

  static Future showCustom(BuildContext context, {required Widget Function(BuildContext) builder, bool isDismissible = true}) {
    return showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        isDismissible: isDismissible,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: builder);
  }

  static Widget _other(BuildContext context, {required List<ModalSheetOption> options, String? title, String? message}) {
    final AppTextStyles textStyles = AppTextStyles.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message != null)
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: textStyles.bodyLarge.text(message, textAlign: TextAlign.center, fontWeightOverride: FontWeight.w500),
              ),
            Column(children: [
              ...options.map((o) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: _otherAction(context, label: o.label, onTap: o.onTap, primary: o.primary, secondary: o.secondary),
                  )),
            ])
          ],
        ),
      ),
    );
  }

  static Widget _otherAction(BuildContext context,
      {required String label, void Function()? onTap, Color? primary, Color? secondary}) {
    return CustomButton.primary(
      text: label,
      onPressed: () {
        Navigator.of(context).pop("Close");
        onTap?.call();
      },
    );
  }

  static CupertinoActionSheet _cupertino(BuildContext context,
      {required List<ModalSheetOption> options, String? title, String? message}) {
    return CupertinoActionSheet(
        title: title == null ? null : Text(title),
        message: message == null ? null : Text(message),
        actions: options
            .map((o) => _cupertinoAction(context, label: o.label, child: o.child, color: o.primary, onTap: o.onTap))
            .toList(),
        cancelButton: ModalSheetUtils._cupertinoAction(context, label: 'Abbrechen'));
  }

  static CupertinoActionSheetAction _cupertinoAction(BuildContext context,
      {required String label, Widget? child, void Function()? onTap, Color? color}) {
    return CupertinoActionSheetAction(
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop("Close");
          onTap?.call();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (child != null) child,
            Text(label, style: TextStyle(color: color)),
          ],
        ));
  }
}
