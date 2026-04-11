import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  late final GetStorage _storage;

  GetStorage get storage => _storage;

  Future<StorageService> init() async {
    await GetStorage.init();
    _storage = GetStorage();
    return this;
  }

  // Save installation configuration
  void saveInstallConfig({
    required String installPath,
    required String apiHost,
    required int apiPort,
    required int insightsPort,
    required int webPort,
    required String postgresPassword,
    required String redisPassword,
  }) {
    _storage.write('install_path', installPath);
    _storage.write('api_host', apiHost);
    _storage.write('api_port', apiPort);
    _storage.write('insights_port', insightsPort);
    _storage.write('web_port', webPort);
    _storage.write('postgres_password', postgresPassword);
    _storage.write('redis_password', redisPassword);
    _storage.write('installation_completed', true);
    _storage.write('installation_date', DateTime.now().toIso8601String());
  }

  // Check if installation is complete
  bool get isInstallationCompleted =>
      _storage.read('installation_completed') ?? false;

  // Get installation path
  String? get installPath => _storage.read('install_path');

  // Clear all data
  void clearAll() {
    _storage.erase();
  }
}
