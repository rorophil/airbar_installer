import 'package:get/get.dart';
import 'package:process_run/shell.dart';
import '../../../../services/storage_service.dart';

enum UpdateStatus {
  checking,
  available,
  upToDate,
  downloading,
  updating,
  error,
}

class UpdateController extends GetxController {
  final _storageService = Get.find<StorageService>();
  final _shell = Shell();

  final status = UpdateStatus.checking.obs;
  final errorMessage = ''.obs;
  final currentVersion = ''.obs;
  final latestVersion = ''.obs;
  final updateProgress = 0.0.obs;
  final updateLogs = <String>[].obs;

  String get installPath =>
      _storageService.storage.read('install_path') ?? 'C:\\AirBar';

  @override
  void onInit() {
    super.onInit();
    checkForUpdates();
  }

  Future<void> checkForUpdates() async {
    try {
      status.value = UpdateStatus.checking;
      errorMessage.value = '';
      updateLogs.clear();

      _addLog('🔍 Vérification de la version actuelle...');

      // Get current version from git
      try {
        final result = await _shell.run(
          'cd "$installPath" && git describe --tags --always',
        );
        if (result.isNotEmpty) {
          currentVersion.value = result.first.stdout.toString().trim();
          _addLog('✅ Version actuelle: ${currentVersion.value}');
        }
      } catch (e) {
        currentVersion.value = 'Inconnue';
        _addLog('⚠️ Impossible de déterminer la version actuelle');
      }

      _addLog('🌐 Recherche des mises à jour sur GitHub...');

      // Fetch latest version from GitHub
      try {
        await _shell.run('cd "$installPath" && git fetch origin');
        final result = await _shell.run(
          'cd "$installPath" && git describe --tags --always origin/main',
        );
        if (result.isNotEmpty) {
          latestVersion.value = result.first.stdout.toString().trim();
          _addLog('✅ Dernière version: ${latestVersion.value}');
        }
      } catch (e) {
        throw Exception('Impossible de récupérer la dernière version');
      }

      // Compare versions
      if (currentVersion.value == latestVersion.value) {
        status.value = UpdateStatus.upToDate;
        _addLog('✅ Le serveur est à jour');
      } else {
        status.value = UpdateStatus.available;
        _addLog('🎉 Une nouvelle version est disponible !');
      }
    } catch (e) {
      status.value = UpdateStatus.error;
      errorMessage.value = e.toString();
      _addLog('❌ Erreur: ${e.toString()}');
    }
  }

  Future<void> performUpdate() async {
    try {
      status.value = UpdateStatus.downloading;
      updateProgress.value = 0.0;

      _addLog('📥 Téléchargement de la mise à jour...');

      // Pull latest code
      await _shell.run('cd "$installPath" && git pull origin main');
      updateProgress.value = 0.3;
      _addLog('✅ Code téléchargé');

      _addLog('🛑 Arrêt des services...');
      status.value = UpdateStatus.updating;

      // Stop containers
      await _shell.run('cd "$installPath" && docker-compose down');
      updateProgress.value = 0.5;
      _addLog('✅ Services arrêtés');

      _addLog('🏗️ Reconstruction de l\'image Docker...');

      // Rebuild Docker image
      await _shell.run('cd "$installPath" && docker-compose build');
      updateProgress.value = 0.8;
      _addLog('✅ Image reconstruite');

      _addLog('🚀 Démarrage des services...');

      // Start containers
      await _shell.run('cd "$installPath" && docker-compose up -d');
      updateProgress.value = 1.0;
      _addLog('✅ Services démarrés');

      _addLog('✅ Mise à jour terminée avec succès !');

      Get.snackbar(
        'Mise à jour réussie',
        'Le serveur a été mis à jour vers ${latestVersion.value}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );

      // Refresh status
      await Future.delayed(const Duration(seconds: 2));
      await checkForUpdates();
    } catch (e) {
      status.value = UpdateStatus.error;
      errorMessage.value = 'Erreur lors de la mise à jour: ${e.toString()}';
      _addLog('❌ ${errorMessage.value}');

      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _addLog(String message) {
    updateLogs.add(message);
  }
}
