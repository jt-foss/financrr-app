import 'package:financrr_frontend/data/repositories.dart';

class HostPreferences {
  final String hostUrl;

  const HostPreferences({this.hostUrl = ""});

  HostPreferences copyWith({String? hostUrl}) {
    return HostPreferences(hostUrl: hostUrl ?? this.hostUrl);
  }
}

class HostRepository extends Repository<HostPreferences> {
  HostRepository({required super.preferences});

  @override
  String get prefix => 'host_prefs';

  @override
  List<String> get keys => ['host_url'];

  @override
  List<RepositoryItem<HostPreferences>> fromData() {
    return [
      RepositoryItem(key: keys[0], applyFunction: (d) => d.hostUrl),
    ];
  }

  @override
  HostPreferences toData(Map<String, Object?> items) {
    return HostPreferences(hostUrl: (items[keys[0]] ?? '') as String);
  }
}

class HostService {
  const HostService._();

  static HostPreferences get() => Repositories.hostRepository.read();

  static Future<HostPreferences> setHostPreferences(String hostUrl) async {
    final HostPreferences preferences = HostPreferences(hostUrl: hostUrl);
    await Repositories.hostRepository.save(preferences);
    return preferences;
  }
}
