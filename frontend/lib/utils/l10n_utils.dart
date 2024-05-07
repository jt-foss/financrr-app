import 'package:easy_localization/easy_localization.dart';
import 'package:financrr_frontend/utils/extensions.dart';
import 'package:flutter/material.dart';

enum L10nKey {
  appearanceCurrentDarkTheme('appearance_current_dark_theme'),
  appearanceCurrentDeviceTheme('appearance_current_device_theme'),
  appearanceCurrentLightTheme('appearance_current_light_theme'),
  appearanceUseDeviceTheme('appearance_use_device_theme'),
  authConfigCheckUrl('auth_config_check_url'),
  authConfigStatus('auth_config_status', hasParams: true),
  authLoginFailed('auth_login_failed'),
  authLoginMessage1('auth_login_message_1'),
  authLoginMessage2('auth_login_message_2'),
  authLoginMessage3('auth_login_message_3'),
  authLoginMessage4('auth_login_message_4'),
  authLoginMessage5('auth_login_message_5'),
  authLoginNoAccount('auth_login_no_account'),
  authRegisterExistingAccount('auth_register_existing_account'),
  authRegisterFailed('auth_register_failed'),
  authRegisterMessage1('auth_register_message_1'),
  authRegisterMessage2('auth_register_message_2'),
  authRegisterMessage3('auth_register_message_3'),
  authRegisterMessage4('auth_register_message_4'),
  authRegisterMessage5('auth_register_message_5'),
  brandName('brand_name'),
  commonCreate('common_create'),
  commonCreateObject('common_create_object', hasParams: true),
  commonCreateObjectSuccess('common_create_object_success', hasParams: true),
  commonDeleteAll('common_delete_all'),
  commonDeleteObjectSuccess('common_delete_object_success', hasParams: true),
  commonEditObject('common_edit_object', hasParams: true),
  commonEditObjectSuccess('common_edit_object_success', hasParams: true),
  commonLoadMore('common_load_more'),
  commonLogin('common_login'),
  commonLogout('common_logout'),
  commonNext('common_next'),
  commonPassword('common_password'),
  commonPasswordNoMatch('common_password_no_match'),
  commonPasswordRepeat('common_password_repeat'),
  commonPasswordRepeatRequired('common_password_repeat_required'),
  commonPasswordRequired('common_password_required'),
  commonPasswordWeak('common_password_weak'),
  commonPreview('common_preview'),
  commonRegister('common_register'),
  commonSave('common_save'),
  commonSaveSuccess('common_save_success'),
  commonSortNewestFirst('common_sort_newest_first'),
  commonSortOldestFirst('common_sort_oldest_first'),
  commonUrlInvalid('common_url_invalid'),
  commonUsername('common_username'),
  commonUsernameRequired('common_username_required'),
  commonVersion('common_version', hasParams: true),
  currencyCreate('currency_create'),
  currencyEdit('currency_edit'),
  currencyNotEditable('currency_not_editable'),
  currencyNotFound('currency_not_found'),
  l10nDateFormat('l10n_date_format'),
  l10nDecimalSeparator('l10n_decimal_separator'),
  l10nThousandsSeparator('l10n_thousands_separator'),
  navigationAccounts('navigation_accounts'),
  navigationDashboard('navigation_dashboard'),
  navigationSettings('navigation_settings'),
  navigationStatistics('navigation_statistics'),
  sessionCurrent('session_current'),
  sessionDeleteAllSuccess('session_delete_all_success'),
  sessionUnnamed('session_unnamed'),
  settingsCategoryAccount('settings_category_account'),
  settingsCategoryApp('settings_category_app'),
  settingsCategoryDeveloper('settings_category_developer'),
  settingsFooter('settings_footer'),
  settingsItemAppearance('settings_item_appearance'),
  settingsItemCurrencies('settings_item_currencies'),
  settingsItemLanguage('settings_item_language'),
  settingsItemLocalStorage('settings_item_local_storage'),
  settingsItemLogs('settings_item_logs'),
  settingsItemSessions('settings_item_sessions'),
  themeDark('theme_dark'),
  themeLight('theme_light'),
  themeMidnight('theme_midnight'),
  ;

  final String key;
  final bool hasParams;
  const L10nKey(this.key, {this.hasParams = false});

  Text toText({Map<String, String>? namedArgs, TextStyle? style, TextAlign? textAlign}) {
    return Text(
      key,
      style: style,
      textAlign: textAlign,
    ).tr(namedArgs: namedArgs);
  }

  void showSnack(BuildContext context, {Map<String, String>? namedArgs}) {
    context.showSnackBar(key.tr(namedArgs: namedArgs));
  }

  @override
  String toString({Map<String, String>? namedArgs}) {
    return key.tr(namedArgs: namedArgs);
  }

  static L10nKey? fromKey(String key) {
    for (L10nKey value in L10nKey.values) {
      if (value.key == key) {
        return value;
      }
    }
    return null;
  }
}
