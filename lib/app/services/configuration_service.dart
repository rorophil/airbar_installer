import 'dart:io';
import 'dart:math';
import 'package:get/get.dart';
import '../core/constants/app_constants.dart';

class ConfigurationService extends GetxService {
  final installPath = AppConstants.defaultInstallPath.obs;
  final apiHost = AppConstants.defaultApiHost.obs;
  final apiPort = AppConstants.defaultApiPort.obs;
  final postgresPassword = ''.obs;
  final redisPassword = ''.obs;

  final isSaving = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    generatePasswords();
  }

  void generatePasswords() {
    postgresPassword.value = _generateSecurePassword();
    redisPassword.value = _generateSecurePassword();
  }

  String _generateSecurePassword({int length = 32}) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()_+-=[]{}|;:,.<>?';
    final random = Random.secure();
    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<bool> createConfigurationFiles({
    String? installPath,
    String? apiHost,
    int? apiPort,
    int? insightsPort,
    int? webPort,
  }) async {
    isSaving.value = true;
    errorMessage.value = '';

    try {
      // Use provided values or fallback to service values
      final path = installPath ?? this.installPath.value;
      final host = apiHost ?? this.apiHost.value;
      final port = apiPort ?? this.apiPort.value;
      final iPort = insightsPort ?? AppConstants.defaultInsightsPort;
      final wPort = webPort ?? AppConstants.defaultWebPort;

      final serverPath = '$path\\airbar_backend\\airbar_backend_server';

      // Create .env file
      await _createEnvFile(serverPath);

      // Create docker-compose.production.yaml
      await _createDockerComposeFile(serverPath, port, iPort, wPort);

      // Update config/production.yaml
      await _updateProductionConfig(serverPath, host, port, iPort, wPort);

      isSaving.value = false;
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      isSaving.value = false;
      return false;
    }
  }

  Future<void> _createEnvFile(String serverPath) async {
    final envContent =
        '''
POSTGRES_USER=postgres
POSTGRES_DB=airbar_backend
POSTGRES_PASSWORD=${postgresPassword.value}
REDIS_PASSWORD=${redisPassword.value}
''';

    final envFile = File('$serverPath\\.env.production');
    await envFile.parent.create(recursive: true);
    await envFile.writeAsString(envContent);
  }

  Future<void> _createDockerComposeFile(
    String serverPath,
    int apiPort,
    int insightsPort,
    int webPort,
  ) async {
    final dockerComposeContent =
        '''
version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: pgvector/pgvector:pg16
    container_name: airbar_postgres
    restart: always
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: postgres
      POSTGRES_DB: airbar_backend
      POSTGRES_PASSWORD: \${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - airbar_network

  # Redis Cache
  redis:
    image: redis:6.2.6
    container_name: airbar_redis
    restart: always
    ports:
      - "6379:6379"
    command: redis-server --requirepass \${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    networks:
      - airbar_network

  # AirBar Server
  airbar_server:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: airbar_server
    restart: always
    ports:
      - "$apiPort:8080"
      - "$insightsPort:8081"
      - "$webPort:8082"
    environment:
      runmode: production
      serverid: server-01
      logging: normal
      role: monolith
    depends_on:
      - postgres
      - redis
    networks:
      - airbar_network
    volumes:
      - ./config:/app/config:ro

networks:
  airbar_network:
    driver: bridge

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local
''';

    final dockerComposeFile = File(
      '$serverPath\\docker-compose.production.yaml',
    );
    await dockerComposeFile.writeAsString(dockerComposeContent);
  }

  Future<void> _updateProductionConfig(
    String serverPath,
    String apiHost,
    int apiPort,
    int insightsPort,
    int webPort,
  ) async {
    final productionConfigContent =
        '''
# Production configuration for AirBar Server
# Generated on ${DateTime.now().toIso8601String()}

apiServer:
  port: 8080
  publicHost: $apiHost
  publicPort: $apiPort
  publicScheme: http

insightsServer:
  port: 8081
  publicHost: $apiHost
  publicPort: $insightsPort
  publicScheme: http

webServer:
  port: 8082
  publicHost: $apiHost
  publicPort: $webPort
  publicScheme: http

database:
  host: postgres
  port: 5432
  name: airbar_backend
  user: postgres
  requireSsl: false

redis:
  enabled: true
  host: redis
  port: 6379

maxRequestSize: 524288

sessionLogs:
  consoleEnabled: true
''';

    final configFile = File('$serverPath\\config\\production.yaml');
    await configFile.parent.create(recursive: true);
    await configFile.writeAsString(productionConfigContent);
  }

  Future<void> _updatePasswordsYaml(String serverPath) async {
    final passwordsContent =
        '''
# Passwords configuration
# Generated on ${DateTime.now().toIso8601String()}

production:
  database: '${postgresPassword.value}'
  redis: '${redisPassword.value}'
''';

    final passwordsFile = File('$serverPath\\config\\passwords.yaml');
    await passwordsFile.writeAsString(passwordsContent);
  }

  Map<String, dynamic> getConfigSummary() {
    return {
      'installPath': installPath.value,
      'apiHost': apiHost.value,
      'apiPort': apiPort.value,
      'apiUrl': 'http://${apiHost.value}:${apiPort.value}',
      'insightsUrl':
          'http://${apiHost.value}:${AppConstants.defaultInsightsPort}',
      'webUrl': 'http://${apiHost.value}:${AppConstants.defaultWebPort}',
    };
  }

  void setInstallPath(String path) {
    installPath.value = path;
  }

  void setApiHost(String host) {
    apiHost.value = host;
  }

  void setApiPort(int port) {
    apiPort.value = port;
  }
}
