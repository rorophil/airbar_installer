import 'dart:io';
import 'package:get/get.dart';
import 'package:process_run/process_run.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../core/constants/app_constants.dart';

enum DockerStatus { notInstalled, installing, installed, running, error }

class DockerService extends GetxService {
  final status = DockerStatus.notInstalled.obs;
  final isInstalling = false.obs;
  final installProgress = 0.0.obs;
  final installMessage = ''.obs;
  final errorMessage = ''.obs;

  final _dio = Dio();

  @override
  void onInit() {
    super.onInit();
    checkDockerStatus();
  }

  Future<void> checkDockerStatus() async {
    try {
      final result = await Shell().run('docker --version');

      if (result.isNotEmpty && result.first.exitCode == 0) {
        status.value = DockerStatus.installed;

        // Check if Docker daemon is running
        try {
          final psResult = await Shell().run('docker ps');
          if (psResult.isNotEmpty && psResult.first.exitCode == 0) {
            status.value = DockerStatus.running;
          }
        } catch (e) {
          // Docker installed but daemon not running
          status.value = DockerStatus.installed;
        }
      } else {
        status.value = DockerStatus.notInstalled;
      }
    } catch (e) {
      status.value = DockerStatus.notInstalled;
    }
  }

  Future<bool> installDocker() async {
    if (isInstalling.value) return false;

    isInstalling.value = true;
    status.value = DockerStatus.installing;
    errorMessage.value = '';

    try {
      // Step 1: Download Docker Desktop installer
      installMessage.value = 'Téléchargement de Docker Desktop...';
      installProgress.value = 0.0;

      final tempDir = await getTemporaryDirectory();
      final installerPath = '${tempDir.path}\\Docker_Desktop_Installer.exe';

      await _dio.download(
        AppConstants.dockerDesktopURL,
        installerPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            installProgress.value = (received / total * 0.5); // 0-50%
          }
        },
      );

      // Step 2: Run installer
      installMessage.value = 'Installation de Docker Desktop en cours...';
      installProgress.value = 0.6;

      // Run installer (may require admin privileges)
      final result = await Shell().run(
        '$installerPath install --quiet --accept-license',
      );

      if (result.isEmpty || result.first.exitCode != 0) {
        throw Exception('L\'installation de Docker a échoué');
      }

      installProgress.value = 0.8;
      installMessage.value = 'Vérification de l\'installation...';

      // Wait a bit for installation to complete
      await Future.delayed(const Duration(seconds: 5));

      // Step 3: Verify installation
      await checkDockerStatus();

      if (status.value == DockerStatus.installed ||
          status.value == DockerStatus.running) {
        installProgress.value = 1.0;
        installMessage.value = 'Docker Desktop installé avec succès';
        isInstalling.value = false;

        // Clean up installer
        try {
          await File(installerPath).delete();
        } catch (e) {
          // Ignore cleanup errors
        }

        return true;
      } else {
        throw Exception('Docker installé mais non détecté');
      }
    } catch (e) {
      status.value = DockerStatus.error;
      errorMessage.value = e.toString();
      installMessage.value = 'Erreur lors de l\'installation';
      isInstalling.value = false;
      return false;
    }
  }

  Future<bool> waitForDockerDaemon({
    Duration timeout = const Duration(minutes: 5),
  }) async {
    installMessage.value = 'Attente du démarrage de Docker...';
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < timeout) {
      try {
        final result = await Shell().run('docker ps');
        if (result.isNotEmpty && result.first.exitCode == 0) {
          status.value = DockerStatus.running;
          installMessage.value = 'Docker est prêt';
          return true;
        }
      } catch (e) {
        // Continue waiting
      }

      await Future.delayed(const Duration(seconds: 5));
    }

    errorMessage.value = 'Timeout: Docker daemon n\'a pas démarré';
    return false;
  }

  Future<bool> startDockerDesktop() async {
    try {
      installMessage.value = 'Démarrage de Docker Desktop...';

      // Try to start Docker Desktop
      await Shell().run(
        'start "" "C:\\Program Files\\Docker\\Docker\\Docker Desktop.exe"',
      );

      // Wait for daemon to start
      return await waitForDockerDaemon();
    } catch (e) {
      errorMessage.value = 'Impossible de démarrer Docker Desktop: $e';
      return false;
    }
  }

  String getDockerVersion() {
    // This should be called after checking Docker is installed
    // Returns the version string
    return 'Docker version (à implémenter)';
  }
}
