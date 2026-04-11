import 'package:get/get.dart';
import 'package:process_run/shell.dart';
import '../../../../services/storage_service.dart';

enum ServiceStatus { running, stopped, error, unknown }

class ServiceInfo {
  final String name;
  final ServiceStatus status;
  final String? containerId;
  final String? uptime;
  final String? cpuUsage;
  final String? memoryUsage;

  ServiceInfo({
    required this.name,
    required this.status,
    this.containerId,
    this.uptime,
    this.cpuUsage,
    this.memoryUsage,
  });
}

class DashboardController extends GetxController {
  final _storageService = Get.find<StorageService>();
  final _shell = Shell();

  final services = <ServiceInfo>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final lastUpdateTime = DateTime.now().obs;

  String get installPath =>
      _storageService.storage.read('install_path') ?? 'C:\\AirBar';
  String get apiHost => _storageService.storage.read('api_host') ?? 'localhost';
  int get apiPort => _storageService.storage.read('api_port') ?? 8080;

  @override
  void onInit() {
    super.onInit();
    loadServicesStatus();
    // Auto-refresh every 30 seconds
    ever(
      lastUpdateTime,
      (_) => Future.delayed(const Duration(seconds: 30), loadServicesStatus),
    );
  }

  Future<void> loadServicesStatus() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final servicesList = <ServiceInfo>[];

      // Check Docker containers status
      try {
        final result = await _shell.run(
          'docker ps --filter "name=airbar" --format "{{.Names}}|{{.ID}}|{{.Status}}"',
        );

        if (result.isNotEmpty && result.first.stdout.toString().isNotEmpty) {
          final lines = result.first.stdout.toString().trim().split('\n');

          for (final line in lines) {
            if (line.isEmpty) continue;

            final parts = line.split('|');
            if (parts.length >= 3) {
              final name = parts[0];
              final containerId = parts[1];
              final statusText = parts[2];

              // Parse uptime from status (e.g., "Up 2 hours")
              String? uptime;
              if (statusText.contains('Up')) {
                uptime = statusText;
              }

              // Get CPU and memory usage
              String? cpuUsage;
              String? memoryUsage;
              try {
                final statsResult = await _shell.run(
                  'docker stats $containerId --no-stream --format "{{.CPUPerc}}|{{.MemUsage}}"',
                );
                if (statsResult.isNotEmpty) {
                  final stats = statsResult.first.stdout
                      .toString()
                      .trim()
                      .split('|');
                  if (stats.length >= 2) {
                    cpuUsage = stats[0];
                    memoryUsage = stats[1];
                  }
                }
              } catch (e) {
                // Ignore stats errors
              }

              servicesList.add(
                ServiceInfo(
                  name: name,
                  status: statusText.contains('Up')
                      ? ServiceStatus.running
                      : ServiceStatus.stopped,
                  containerId: containerId,
                  uptime: uptime,
                  cpuUsage: cpuUsage,
                  memoryUsage: memoryUsage,
                ),
              );
            }
          }
        }
      } catch (e) {
        errorMessage.value = 'Erreur lors de la récupération de l\'état Docker';
      }

      // If no services found, add default services with unknown status
      if (servicesList.isEmpty) {
        servicesList.addAll([
          ServiceInfo(name: 'airbar_server', status: ServiceStatus.unknown),
          ServiceInfo(name: 'postgres', status: ServiceStatus.unknown),
          ServiceInfo(name: 'redis', status: ServiceStatus.unknown),
        ]);
      }

      services.value = servicesList;
      lastUpdateTime.value = DateTime.now();
    } catch (e) {
      errorMessage.value = 'Erreur: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startService(String serviceName) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _shell.run('docker start $serviceName');

      Get.snackbar(
        'Service démarré',
        '$serviceName a été démarré avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );

      await loadServicesStatus();
    } catch (e) {
      errorMessage.value = 'Erreur lors du démarrage: ${e.toString()}';
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> stopService(String serviceName) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _shell.run('docker stop $serviceName');

      Get.snackbar(
        'Service arrêté',
        '$serviceName a été arrêté avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );

      await loadServicesStatus();
    } catch (e) {
      errorMessage.value = 'Erreur lors de l\'arrêt: ${e.toString()}';
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> restartService(String serviceName) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _shell.run('docker restart $serviceName');

      Get.snackbar(
        'Service redémarré',
        '$serviceName a été redémarré avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );

      await loadServicesStatus();
    } catch (e) {
      errorMessage.value = 'Erreur lors du redémarrage: ${e.toString()}';
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogs() => Get.toNamed('/management/logs');
  void goToBackups() => Get.toNamed('/management/backups');
  void goToConfig() => Get.toNamed('/management/config');
  void goToUpdate() => Get.toNamed('/management/update');
  void goToUninstall() => Get.toNamed('/management/uninstall');
}
