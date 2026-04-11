import 'package:get/get.dart';
import 'package:process_run/shell.dart';
import 'dart:io';
import '../../../../services/storage_service.dart';

class BackupInfo {
  final String filename;
  final DateTime createdAt;
  final int sizeBytes;
  final String type; // 'database' or 'full'

  BackupInfo({
    required this.filename,
    required this.createdAt,
    required this.sizeBytes,
    required this.type,
  });

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024)
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    if (sizeBytes < 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class BackupsController extends GetxController {
  final _storageService = Get.find<StorageService>();
  final _shell = Shell();

  final backups = <BackupInfo>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isCreatingBackup = false.obs;
  final backupProgress = 0.0.obs;

  String get installPath =>
      _storageService.storage.read('install_path') ?? 'C:\\AirBar';
  String get backupsPath => '$installPath\\backups';

  @override
  void onInit() {
    super.onInit();
    loadBackups();
  }

  Future<void> loadBackups() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Create backups directory if it doesn't exist
      final backupsDir = Directory(backupsPath);
      if (!await backupsDir.exists()) {
        await backupsDir.create(recursive: true);
      }

      // List all backup files
      final backupsList = <BackupInfo>[];
      await for (final entity in backupsDir.list()) {
        if (entity is File && entity.path.endsWith('.sql')) {
          final stat = await entity.stat();
          final filename = entity.path.split('\\').last;

          // Parse backup type and date from filename
          // Format: airbar_backup_YYYY-MM-DD_HH-MM-SS.sql
          String type = 'database';
          if (filename.contains('full')) {
            type = 'full';
          }

          backupsList.add(
            BackupInfo(
              filename: filename,
              createdAt: stat.modified,
              sizeBytes: stat.size,
              type: type,
            ),
          );
        }
      }

      // Sort by date (newest first)
      backupsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      backups.value = backupsList;
    } catch (e) {
      errorMessage.value =
          'Erreur lors du chargement des sauvegardes: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createBackup({bool fullBackup = false}) async {
    try {
      isCreatingBackup.value = true;
      backupProgress.value = 0.0;
      errorMessage.value = '';

      // Create backups directory if it doesn't exist
      final backupsDir = Directory(backupsPath);
      if (!await backupsDir.exists()) {
        await backupsDir.create(recursive: true);
      }

      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')[0];
      final backupType = fullBackup ? 'full' : 'db';
      final backupFilename = 'airbar_${backupType}_backup_$timestamp.sql';
      final backupPath = '$backupsPath\\$backupFilename';

      backupProgress.value = 0.2;

      // Get PostgreSQL password
      final postgresPassword =
          _storageService.storage.read('postgres_password') ?? '';

      backupProgress.value = 0.4;

      // Create database dump using docker exec
      await _shell.run(
        'docker exec -e PGPASSWORD=$postgresPassword postgres pg_dump -U postgres airbar > "$backupPath"',
      );

      backupProgress.value = 0.8;

      // If full backup, also backup configuration files
      if (fullBackup) {
        // TODO: Add configuration files backup
      }

      backupProgress.value = 1.0;

      Get.snackbar(
        'Sauvegarde créée',
        'La sauvegarde $backupFilename a été créée avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );

      await loadBackups();
    } catch (e) {
      errorMessage.value =
          'Erreur lors de la création de la sauvegarde: ${e.toString()}';
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isCreatingBackup.value = false;
      backupProgress.value = 0.0;
    }
  }

  Future<void> restoreBackup(BackupInfo backup) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final backupPath = '$backupsPath\\${backup.filename}';

      // Get PostgreSQL password
      final postgresPassword =
          _storageService.storage.read('postgres_password') ?? '';

      // Stop the server container first
      await _shell.run('docker stop airbar_server');

      // Restore database
      await _shell.run(
        'docker exec -i -e PGPASSWORD=$postgresPassword postgres psql -U postgres airbar < "$backupPath"',
      );

      // Restart the server
      await _shell.run('docker start airbar_server');

      Get.snackbar(
        'Restauration réussie',
        'La base de données a été restaurée avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Erreur lors de la restauration: ${e.toString()}';
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBackup(BackupInfo backup) async {
    try {
      final backupFile = File('$backupsPath\\${backup.filename}');
      if (await backupFile.exists()) {
        await backupFile.delete();

        Get.snackbar(
          'Sauvegarde supprimée',
          '${backup.filename} a été supprimée',
          snackPosition: SnackPosition.BOTTOM,
        );

        await loadBackups();
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la suppression: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> exportBackup(BackupInfo backup) async {
    try {
      // In a real implementation, use file_picker to save the file
      Get.snackbar(
        'Export',
        'La sauvegarde ${backup.filename} serait exportée',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      // TODO: Implement actual file export using file_picker package
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de l\'export: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
