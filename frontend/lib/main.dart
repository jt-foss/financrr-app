import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:financrr_frontend/modules/settings/models/log_store.dart';
import 'package:financrr_frontend/routing/router.dart';
import 'package:financrr_frontend/shared/models/store.dart';
import 'package:financrr_frontend/shared/models/themes.dart';
import 'package:financrr_frontend/shared/ui/fallback_error_app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'modules/settings/models/log_entry.model.dart';

Logger _log = Logger('GenericLogger');

void main() async {
  // if an error occurs during initialization, show a fallback error app
  Widget app;
  try {
    app = await initApp();
  } catch (e, stackTrace) {
    app = FallbackErrorApp(error: e.toString(), stackTrace: stackTrace.toString());
  }
  runApp(app);
}

Future<Widget> initApp() async {
  usePathUrlStrategy();
  await initializeDateFormatting();
  SharedPreferences.setPrefix('financrr.');
  WidgetsFlutterBinding.ensureInitialized();

  // init l10ns
  await EasyLocalization.ensureInitialized();

  // init store
  await KeyValueStore.init();

  // init logging
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    _log.severe(
        'FlutterError: ${details.exceptionAsString()}\n\nLibrary: ${details.library}\n\nContext: ${details.context}\n\nStackTrace: ${details.stack}');
  };
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((event) {
    if (kDebugMode) {
      print('${event.level.name}: ${event.time}: ${event.message}');
    }
    LogEntryStore().add(LogEntry(
        level: LogLevel.values.byName(event.level.name.toLowerCase()),
        message: event.message,
        timestamp: event.time,
        loggerName: event.loggerName));
  });

  // init themes
  await AppThemeLoader.init();
  final ThemeMode themeMode = (await StoreKey.themeMode.readAsync())!;
  final AppTheme lightTheme = AppTheme.getById((await StoreKey.currentLightThemeId.readAsync())!)!;
  final AppTheme darkTheme = AppTheme.getById((await StoreKey.currentDarkThemeId.readAsync())!)!;

  return ProviderScope(
    child: EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('de', 'DE')],
        path: 'assets/l10n',
        fallbackLocale: const Locale('en', 'US'),
        child: FinancrrApp(themeMode: themeMode, currentLightTheme: lightTheme, currentDarkTheme: darkTheme)),
  );
}

class FinancrrApp extends StatefulHookConsumerWidget {
  final ThemeMode themeMode;
  final AppTheme currentLightTheme;
  final AppTheme currentDarkTheme;

  const FinancrrApp(
      {super.key, required this.themeMode, required this.currentLightTheme, required this.currentDarkTheme});

  @override
  ConsumerState<FinancrrApp> createState() => FinancrrAppState();

  static FinancrrAppState of(BuildContext context) => context.findAncestorStateOfType<FinancrrAppState>()!;
}

class FinancrrAppState extends ConsumerState<FinancrrApp> {
  late AppTheme _activeLightTheme = widget.currentLightTheme;
  late AppTheme _activeDarkTheme = widget.currentDarkTheme;
  late ThemeMode _themeMode = widget.themeMode;

  ThemeMode get themeMode => _themeMode;
  AppTheme get activeLightTheme => _activeLightTheme;
  AppTheme get activeDarkTheme => _activeDarkTheme;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    var router = ref.watch(appRouterProvider);

    return MaterialApp.router(
        onGenerateTitle: (ctx) => 'brand_name'.tr(),
        routerConfig: router.goRouter,
        debugShowCheckedModeBanner: false,
        scrollBehavior: CustomScrollBehavior(),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: _activeLightTheme.themeData,
        darkTheme: _activeDarkTheme.themeData,
        themeMode: _themeMode);
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
      StoreKey.currentLightThemeId.write(_activeLightTheme.id);
      StoreKey.currentDarkThemeId.write(_activeDarkTheme.id);
      StoreKey.themeMode.write(_themeMode);
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
