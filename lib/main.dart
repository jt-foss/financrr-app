import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/router.dart';
import 'package:financrr_frontend/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  setPathUrlStrategy();
  runApp(const FinancrrApp());
}

class FinancrrApp extends StatefulWidget {
  const FinancrrApp({super.key});

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
    // TODO: implement repositories
    // _activeLightTheme = widget.themePreferences.currentLightTheme;
    // _activeDarkTheme = widget.themePreferences.currentDarkTheme;
    // _themeMode = widget.themePreferences.themeMode;
    _themeMode = ThemeMode.light;
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
      // ThemeService.setThemePreferences(_activeLightTheme, _activeDarkTheme, _themeMode);
    });
  }
}
