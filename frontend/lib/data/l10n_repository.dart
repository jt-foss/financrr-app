import 'package:financrr_frontend/data/repositories.dart';
import 'package:intl/intl.dart';

final DateFormat dateTimeFormat = DateFormat(L10nService.get().dateTimeFormat);
final String decimalSeparator = L10nService.get().decimalSeparator;

class L10nPreferences {
  final String dateTimeFormat;
  final String decimalSeparator;

  const L10nPreferences({this.dateTimeFormat = 'yyyy-MM-dd HH:mm', this.decimalSeparator = '.'});

  L10nPreferences copyWith({String? dateTimeFormat, String? decimalSeparator}) {
    return L10nPreferences(
        dateTimeFormat: dateTimeFormat ?? this.dateTimeFormat,
        decimalSeparator: decimalSeparator ?? this.decimalSeparator);
  }
}

class L10nRepository extends Repository<L10nPreferences> {
  L10nRepository({required super.preferences});

  @override
  String get prefix => 'l10n_prefs';

  @override
  List<String> get keys => ['date_time_format', 'decimal_separator'];

  @override
  List<RepositoryItem<L10nPreferences>> fromData() {
    return [
      RepositoryItem(key: keys[0], applyFunction: (d) => d.dateTimeFormat),
      RepositoryItem(key: keys[1], applyFunction: (d) => d.decimalSeparator),
    ];
  }

  @override
  L10nPreferences toData(Map<String, Object?> items) {
    const L10nPreferences defaultPrefs = L10nPreferences();
    return L10nPreferences(
        dateTimeFormat: (items[keys[0]] ?? defaultPrefs.dateTimeFormat) as String,
        decimalSeparator: (items[keys[1]] ?? defaultPrefs.decimalSeparator) as String);
  }
}

class L10nService {
  const L10nService._();

  static L10nPreferences get() => Repositories.l10nRepository.read();

  static Future<L10nPreferences> setL10nPreferences({String? dateTimeFormat, String? decimalSeparator}) async {
    final L10nPreferences preferences =
        get().copyWith(dateTimeFormat: dateTimeFormat, decimalSeparator: decimalSeparator);
    await Repositories.l10nRepository.save(preferences);
    return preferences;
  }
}
