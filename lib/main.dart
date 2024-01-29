import 'package:financrr_frontend/data/repositories.dart';
import 'package:financrr_frontend/router.dart';
import 'package:financrr_frontend/themes.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_strategy/url_strategy.dart';

import 'data/theme_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  SharedPreferences.setPrefix('financrr.');
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  const FlutterSecureStorage storage = FlutterSecureStorage();
  await Repositories.init(storage, preferences);
  final EffectiveThemePreferences themePreferences = await ThemeService.getOrInsertEffective();
  runApp(FinancrrApp(themePreferences: themePreferences));
}

class FinancrrApp extends StatefulWidget {
  final EffectiveThemePreferences themePreferences;

  const FinancrrApp({super.key, required this.themePreferences});

  @override
  State<FinancrrApp> createState() => FinancrrAppState();

  static FinancrrAppState of(BuildContext context) => context.findAncestorStateOfType<FinancrrAppState>()!;
}

class FinancrrAppState extends State<FinancrrApp> {
  AppTheme _activeLightTheme = AppThemes.light();
  AppTheme _activeDarkTheme = AppThemes.dark();
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  AppTheme get activeLightTheme => _activeLightTheme;
  AppTheme get activeDarkTheme => _activeDarkTheme;

  @override
  void initState() {
    super.initState();
    _activeLightTheme = widget.themePreferences.currentLightTheme;
    _activeDarkTheme = widget.themePreferences.currentDarkTheme;
    _themeMode = widget.themePreferences.themeMode;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthenticationNotifier(),
      child: MaterialApp.router(
          onGenerateTitle: (ctx) => ctx.locale.brandName,
          routerConfig: AppRouter.goRouter,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: _activeLightTheme.themeData,
          darkTheme: _activeDarkTheme.themeData,
          themeMode: _themeMode),
    );
  }

  /// Gets the currently active [AppTheme].
  AppTheme getAppTheme() {
    if (_themeMode == ThemeMode.light) {
      return _activeLightTheme;
    }
    if (_themeMode == ThemeMode.dark) {
      return _activeDarkTheme;
    }
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.light
        ? _activeLightTheme
        : _activeDarkTheme;
  }

  void changeAppTheme({required AppTheme theme, bool system = false}) {
    setState(() {
      if (theme.themeMode == ThemeMode.light) {
        _activeLightTheme = theme;
      }
      if (theme.themeMode == ThemeMode.dark) {
        _activeDarkTheme = theme;
      }
      _themeMode = system ? ThemeMode.system : theme.themeMode;
      ThemeService.setThemePreferences(_activeLightTheme, _activeDarkTheme, _themeMode);
    });
  }
}
