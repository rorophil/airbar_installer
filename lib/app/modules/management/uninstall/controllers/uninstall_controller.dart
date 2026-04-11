import 'package:get/get.dart';
import 'package:process_run/shell.dart';
import 'dart:io';
import '../../../../services/storage_service.dart';

class UninstallStep {
  final String title;
  final String description;
  final bool isCompleted;
  final bool isInProgress;
  final bool hasError;
  final String? errorMessage;

  UninstallStep({
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.isInProgress = false,
    this.hasError = false,
    this.errorMessage,
  });
}

class UninstallController extends GetxController {
  final _storageService = Get.find<StorageService>();
  final _shell = Shell();

  final isUninstalling = false.obs;
  final uninstallProgress = 0.0.obs;
  final steps = <UninstallStep>[].obs;
  final uninstallLogs = <String>[].obs;
  final errorMessage = ''.obs;

  // Options
  final removeData = true.obs;
  final removeBackups = false.obs;
  final removeDocker = false.obs;

  String get installPath =>
      _storageService.storage.read('install_path') ?? 'C:\\AirBar';

  @override
  void onInit() {
    super.onInit();
    _initializeSteps();
  }

  void _initializeSteps() {
    steps.value = [
      UninstallStep(
        title: 'Arrêt des services',
        description: 'Arrêt des conteneurs Docker',
      ),
      UninstallStep(
        title: 'Suppression des conteneurs',
        description: 'Suppression des conteneurs et volumes Docker',
      ),
      UninstallStep(
        title: 'Suppression des fichiers',
        description: 'Suppression du répertoire d\'installation',
      ),
      UninstallStep(
        title: 'Nettoyage de la configuration',
        description: 'Suppression des fichiers de configuration',
      ),
      UninstallStep(
        title: 'Suppression des règles firewall',
        description: 'Nettoyage des règles de pare-feu',
      ),
    ];
  }

  Future<void> performUninstall() async {
    try {
      isUninstalling.value = true;
      uninstallProgress.value = 0.0;
      errorMessage.value = '';
      uninstallLogs.clear();

      _addLog('🚀 Démarrage de la désinstallation...');

      // Step 1: Stop services
      await _executeStep(0, () async {
        _addLog('🛑 Arrêt des services Docker...');
        await _shell.run('cd "$installPath" && docker-compose down');
        _addLog('✅ Services arrêtés');
      });

      uninstallProgress.value = 0.2;

      // Step 2: Remove containers and volumes
      await _executeStep(1, () async {
        _addLog('🗑️ Suppression des conteneurs Docker...');

        if (removeData.value) {
          _addLog('⚠️ Suppression des volumes de données...');
          await _shell.run('cd "$installPath" && docker-compose down -v');
          _addLog('✅ Volumes supprimés');
        } else {
          _addLog('ℹ️ Conservation des volumes de données');
          await _shell.run('cd "$installPath" && docker-compose down');
        }

        _addLog('✅ Conteneurs supprimés');
      });

      uninstallProgress.value = 0.4;

      // Step 3: Remove files
      await _executeStep(2, () async {
        if (!removeBackups.value) {
          _addLog('💾 Sauvegarde des backups...');
          final backupsPath = '$installPath\\backups';
          final tempBackupsPath = 'C:\\AirBar_Backups_Temp';

          try {
            final backupsDir = Directory(backupsPath);
            if (await backupsDir.exists()) {
              await backupsDir.rename(tempBackupsPath);
              _addLog('✅ Backups déplacés vers $tempBackupsPath');
            }
          } catch (e) {
            _addLog('⚠️ Erreur lors de la sauvegarde des backups: $e');
          }
        }

        _addLog('🗑️ Suppression du répertoire d\'installation...');
        final installDir = Directory(installPath);
        if (await installDir.exists()) {
          await installDir.delete(recursive: true);
          _addLog('✅ Répertoire supprimé');
        } else {
          _addLog('ℹ️ Répertoire déjà supprimé');
        }
      });

      uninstallProgress.value = 0.6;

      // Step 4: Clean configuration
      await _executeStep(3, () async {
        _addLog('🧹 Nettoyage de la configuration...');
        _storageService.storage.erase();
        _addLog('✅ Configuration effacée');
      });

      uninstallProgress.value = 0.8;

      // Step 5: Remove firewall rules
      await _executeStep(4, () async {
        _addLog('🔥 Suppression des règles du pare-feu...');

        final ports = [8080, 8081, 8082];
        for (final port in ports) {
          try {
            await _shell.run(
              'netsh advfirewall firewall delete rule name="AirBar Port $port"',
            );
            _addLog('✅ Règle pour le port $port supprimée');
          } catch (e) {
            _addLog('⚠️ Pas de règle trouvée pour le port $port');
          }
        }
      });

      uninstallProgress.value = 1.0;
      _addLog('✅ Désinstallation terminée avec succès !');

      Get.snackbar(
        'Désinstallation réussie',
        'AirBar a été désinstallé avec succès',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );

      // Wait before exiting
      await Future.delayed(const Duration(seconds: 2));

      // Exit application
      exit(0);
    } catch (e) {
      errorMessage.value = 'Erreur lors de la désinstallation: ${e.toString()}';
      _addLog('❌ ${errorMessage.value}');

      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUninstalling.value = false;
    }
  }

  Future<void> _executeStep(int index, Future<void> Function() action) async {
    final updatedSteps = List<UninstallStep>.from(steps);

    // Mark as in progress
    updatedSteps[index] = UninstallStep(
      title: steps[index].title,
      description: steps[index].description,
      isInProgress: true,
    );
    steps.value = updatedSteps;

    try {
      await action();

      // Mark as completed
      updatedSteps[index] = UninstallStep(
        title: steps[index].title,
        description: steps[index].description,
        isCompleted: true,
      );
      steps.value = updatedSteps;
    } catch (e) {
      // Mark as error
      updatedSteps[index] = UninstallStep(
        title: steps[index].title,
        description: steps[index].description,
        hasError: true,
        errorMessage: e.toString(),
      );
      steps.value = updatedSteps;
      rethrow;
    }
  }

  void _addLog(String message) {
    uninstallLogs.add(message);
  }
}
