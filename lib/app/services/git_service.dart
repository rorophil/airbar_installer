import 'dart:io';
import 'package:get/get.dart';
import 'package:process_run/process_run.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../core/constants/app_constants.dart';

enum GitStatus { notInstalled, installing, installed, error }

class GitService extends GetxService {
  final status = GitStatus.notInstalled.obs;
  final isInstalling = false.obs;
  final installProgress = 0.0.obs;
  final installMessage = ''.obs;
  final errorMessage = ''.obs;

  final isCloning = false.obs;
  final cloneProgress = 0.0.obs;
  final cloneMessage = ''.obs;

  final _dio = Dio();

  @override
  void onInit() {
    super.onInit();
    checkGitStatus();
  }

  Future<void> checkGitStatus() async {
    try {
      final result = await Shell().run('git --version');

      if (result.isNotEmpty && result.first.exitCode == 0) {
        status.value = GitStatus.installed;
      } else {
        status.value = GitStatus.notInstalled;
      }
    } catch (e) {
      status.value = GitStatus.notInstalled;
    }
  }

  Future<bool> installGit() async {
    if (isInstalling.value) return false;

    isInstalling.value = true;
    status.value = GitStatus.installing;
    errorMessage.value = '';

    try {
      // Step 1: Download Git installer
      installMessage.value = 'Téléchargement de Git pour Windows...';
      installProgress.value = 0.0;

      final tempDir = await getTemporaryDirectory();
      final installerPath = '${tempDir.path}\\Git_Installer.exe';

      await _dio.download(
        AppConstants.gitInstallerURL,
        installerPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            installProgress.value = (received / total * 0.5); // 0-50%
          }
        },
      );

      // Step 2: Run installer
      installMessage.value = 'Installation de Git en cours...';
      installProgress.value = 0.6;

      // Run installer in silent mode with default options
      final result = await Shell().run(
        '$installerPath /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS',
      );

      if (result.isEmpty || result.first.exitCode != 0) {
        throw Exception('L\'installation de Git a échoué');
      }

      installProgress.value = 0.8;
      installMessage.value = 'Vérification de l\'installation...';

      // Wait for installation to complete
      await Future.delayed(const Duration(seconds: 3));

      // Step 3: Verify installation
      await checkGitStatus();

      if (status.value == GitStatus.installed) {
        installProgress.value = 1.0;
        installMessage.value = 'Git installé avec succès';
        isInstalling.value = false;

        // Clean up installer
        try {
          await File(installerPath).delete();
        } catch (e) {
          // Ignore cleanup errors
        }

        return true;
      } else {
        throw Exception('Git installé mais non détecté');
      }
    } catch (e) {
      status.value = GitStatus.error;
      errorMessage.value = e.toString();
      installMessage.value = 'Erreur lors de l\'installation';
      isInstalling.value = false;
      return false;
    }
  }

  Future<bool> cloneRepository(String targetPath) async {
    if (isCloning.value) return false;

    isCloning.value = true;
    cloneMessage.value = 'Clonage du repository AirBar Backend...';
    cloneProgress.value = 0.0;
    errorMessage.value = '';

    try {
      // Ensure target directory exists
      final targetDir = Directory(targetPath);
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      // Change to target directory and clone
      cloneProgress.value = 0.1;

      final shell = Shell(workingDirectory: targetPath);

      // Clone with progress (Git doesn't provide easy progress, so we simulate)
      cloneMessage.value = 'Clonage en cours...';
      cloneProgress.value = 0.3;

      final result = await shell.run(
        'git clone ${AppConstants.githubRepoURL} airbar_backend',
      );

      if (result.isEmpty || result.first.exitCode != 0) {
        throw Exception('Le clonage du repository a échoué');
      }

      cloneProgress.value = 0.8;
      cloneMessage.value = 'Vérification des fichiers...';

      // Verify critical files exist
      final serverPath = '$targetPath\\airbar_backend\\airbar_backend_server';
      final criticalFiles = [
        '$serverPath\\pubspec.yaml',
        '$serverPath\\docker-compose.yaml',
        '$serverPath\\Dockerfile',
      ];

      for (final filePath in criticalFiles) {
        if (!await File(filePath).exists()) {
          throw Exception('Fichier manquant: ${filePath.split('\\').last}');
        }
      }

      cloneProgress.value = 1.0;
      cloneMessage.value = 'Repository cloné avec succès';
      isCloning.value = false;
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      cloneMessage.value = 'Erreur lors du clonage';
      isCloning.value = false;
      return false;
    }
  }

  Future<bool> downloadAsZip(String targetPath) async {
    // Fallback method if Git clone fails
    // Downloads the repository as a ZIP from GitHub
    isCloning.value = true;
    cloneMessage.value = 'Téléchargement du repository en ZIP...';
    cloneProgress.value = 0.0;
    errorMessage.value = '';

    try {
      final zipUrl = '${AppConstants.githubAPIURL}/zipball/main';
      final tempDir = await getTemporaryDirectory();
      final zipPath = '${tempDir.path}\\airbar_backend.zip';

      await _dio.download(
        zipUrl,
        zipPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            cloneProgress.value = (received / total * 0.7); // 0-70%
          }
        },
      );

      cloneMessage.value = 'Extraction des fichiers...';
      cloneProgress.value = 0.8;

      // TODO: Extract ZIP file (requires archive package)
      // For now, this is a placeholder

      cloneProgress.value = 1.0;
      cloneMessage.value = 'Repository téléchargé avec succès';
      isCloning.value = false;
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      cloneMessage.value = 'Erreur lors du téléchargement';
      isCloning.value = false;
      return false;
    }
  }

  String getGitVersion() {
    // Returns the Git version string
    return 'Git version (à implémenter)';
  }
}
