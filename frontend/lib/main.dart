import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:financrr_frontend/data/repositories.dart';
import 'package:financrr_frontend/pages/login/bloc/auth_bloc.dart';
import 'package:financrr_frontend/router.dart';
import 'package:financrr_frontend/themes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_bloc_observer.dart';
import 'data/theme_repository.dart';

void main() async {
  usePathUrlStrategy();
  SharedPreferences.setPrefix('financrr.');
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();

  // init l10n
  await EasyLocalization.ensureInitialized();

  // init data repositories
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  const FlutterSecureStorage storage = FlutterSecureStorage();
  await Repositories.init(storage, preferences);

  // init themes
  await AppThemeLoader.init();
  final EffectiveThemePreferences themePreferences = await ThemeService.getOrInsertEffective();

  // init logging
  Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    }
  });
  runApp(EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('de', 'DE')],
      path: 'assets/l10n',
      fallbackLocale: const Locale('en', 'US'),
      child: FinancrrApp(themePreferences: themePreferences)));
}

class FinancrrApp extends StatefulWidget {
  final EffectiveThemePreferences themePreferences;

  const FinancrrApp({super.key, required this.themePreferences});

  @override
  State<FinancrrApp> createState() => FinancrrAppState();

  static FinancrrAppState of(BuildContext context) => context.findAncestorStateOfType<FinancrrAppState>()!;
}

class FinancrrAppState extends State<FinancrrApp> {
  AppTheme _activeLightTheme = AppTheme.getById('LIGHT')!;
  AppTheme _activeDarkTheme = AppTheme.getById('DARK')!;
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthenticationBloc()..add(const AuthenticationRecoveryRequested()),
      child: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) => AppRouter.goRouter.refresh(),
        child: MaterialApp.router(
            onGenerateTitle: (ctx) => 'brand_name'.tr(),
            routerConfig: AppRouter.goRouter,
            debugShowCheckedModeBanner: false,
            scrollBehavior: CustomScrollBehavior(),
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: _activeLightTheme.themeData,
            darkTheme: _activeDarkTheme.themeData,
            themeMode: _themeMode),
      ),
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

class CustomHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}
