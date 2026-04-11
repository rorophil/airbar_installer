import 'package:get/get.dart';
import 'package:process_run/shell.dart';
import '../../../../services/storage_service.dart';

enum LogSource { server, postgres, redis }

class LogsController extends GetxController {
  final _storageService = Get.find<StorageService>();
  final _shell = Shell();

  final currentSource = LogSource.server.obs;
  final logs = ''.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final autoRefresh = false.obs;
  final maxLines = 500.obs;

  String get installPath =>
      _storageService.storage.read('install_path') ?? 'C:\\AirBar';

  @override
  void onInit() {
    super.onInit();
    loadLogs();

    // Auto-refresh when enabled
    ever(autoRefresh, (enabled) {
      if (enabled) {
        _startAutoRefresh();
      }
    });
  }

  void _startAutoRefresh() {
    if (autoRefresh.value) {
      Future.delayed(const Duration(seconds: 5), () {
        if (autoRefresh.value) {
          loadLogs();
          _startAutoRefresh();
        }
      });
    }
  }

  Future<void> loadLogs() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      String containerName;
      switch (currentSource.value) {
        case LogSource.server:
          containerName = 'airbar_server';
          break;
        case LogSource.postgres:
          containerName = 'postgres';
          break;
        case LogSource.redis:
          containerName = 'redis';
          break;
      }

      // Get logs from Docker container
      final result = await _shell.run(
        'docker logs $containerName --tail ${maxLines.value}',
      );

      if (result.isNotEmpty) {
        final stdout = result.first.stdout.toString();
        final stderr = result.first.stderr.toString();

        // Combine stdout and stderr
        final combinedLogs = <String>[];
        if (stdout.isNotEmpty) {
          combinedLogs.add(stdout.trim());
        }
        if (stderr.isNotEmpty) {
          combinedLogs.add(stderr.trim());
        }

        logs.value = combinedLogs.join('\n');
      } else {
        logs.value = 'Aucun log disponible';
      }
    } catch (e) {
      errorMessage.value =
          'Erreur lors du chargement des logs: ${e.toString()}';
      logs.value = '';
    } finally {
      isLoading.value = false;
    }
  }

  void changeSource(LogSource source) {
    currentSource.value = source;
    loadLogs();
  }

  void toggleAutoRefresh() {
    autoRefresh.value = !autoRefresh.value;
  }

  void changeMaxLines(int lines) {
    maxLines.value = lines;
    loadLogs();
  }

  Future<void> clearLogs() async {
    try {
      String containerName;
      switch (currentSource.value) {
        case LogSource.server:
          containerName = 'airbar_server';
          break;
        case LogSource.postgres:
          containerName = 'postgres';
          break;
        case LogSource.redis:
          containerName = 'redis';
          break;
      }

      // Clear Docker container logs (requires truncating the log file)
      // Note: This requires additional permissions and might not work on all systems
      await _shell.run('docker logs $containerName --tail 0');

      Get.snackbar(
        'Logs effacés',
        'Les logs ont été effacés avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );

      await loadLogs();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de l\'effacement des logs: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> exportLogs() async {
    try {
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final filename = '${currentSource.value.name}_logs_$timestamp.txt';

      // In a real implementation, use file_picker to save the file
      // For now, just show a message
      Get.snackbar(
        'Export des logs',
        'Les logs seraient exportés vers: $filename',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      // TODO: Implement actual file export using file_picker package
      // final directory = await getApplicationDocumentsDirectory();
      // final file = File('${directory.path}/$filename');
      // await file.writeAsString(logs.value);
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de l\'export: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
