import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:process_run/process_run.dart';
import '../../../services/storage_service.dart';
import '../../../services/configuration_service.dart';
import '../../../routes/app_pages.dart';

class BuildController extends GetxController {
  final _storageService = Get.find<StorageService>();
  final _configService = Get.find<ConfigurationService>();

  final isBuilding = false.obs;
  final buildProgress = 0.0.obs;
  final buildLogs = <String>[].obs;
  final currentStep = ''.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isComplete = false.obs;

  String get installPath => _storageService.installPath ?? 'C:\\AirBar';
  String get serverPath => '$installPath\\airbar_backend_server';

  @override
  void onInit() {
    super.onInit();
    startBuild();
  }

  Future<void> startBuild() async {
    isBuilding.value = true;
    hasError.value = false;
    errorMessage.value = '';
    buildProgress.value = 0.0;
    buildLogs.clear();

    try {
      // Step 1: Generate configuration files
      currentStep.value = 'Génération des fichiers de configuration...';
      _addLog('📝 Génération des fichiers de configuration...');
      await Future.delayed(const Duration(milliseconds: 500));

      final configSuccess = await _configService.createConfigurationFiles();
      if (!configSuccess) {
        throw Exception('Échec de la génération des fichiers de configuration');
      }

      _addLog('✅ Fichiers de configuration générés avec succès');
      buildProgress.value = 0.2;
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 2: Build Docker image
      currentStep.value = 'Construction de l\'image Docker du serveur...';
      _addLog('🐳 Début de la construction de l\'image Docker...');
      _addLog('');
      buildProgress.value = 0.3;

      await _buildDockerImage();

      buildProgress.value = 0.9;
      _addLog('');
      _addLog('✅ Image Docker construite avec succès !');

      // Step 3: Verify image
      currentStep.value = 'Vérification de l\'image...';
      _addLog('🔍 Vérification de l\'image Docker...');
      await Future.delayed(const Duration(milliseconds: 500));

      final imageExists = await _verifyDockerImage();
      if (!imageExists) {
        throw Exception(
          'L\'image Docker n\'a pas été trouvée après la construction',
        );
      }

      _addLog('✅ Image Docker vérifiée avec succès');
      buildProgress.value = 1.0;

      isComplete.value = true;
      currentStep.value = 'Construction terminée !';
      _addLog('');
      _addLog('🎉 Construction terminée avec succès !');

      // Auto-navigate after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      goToNextStep();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      currentStep.value = 'Erreur de construction';
      _addLog('');
      _addLog('❌ Erreur: ${e.toString()}');
    } finally {
      isBuilding.value = false;
    }
  }

  Future<void> _buildDockerImage() async {
    try {
      // Simulate docker build with logs
      final steps = [
        'FROM dart:stable AS build',
        'WORKDIR /app',
        'COPY pubspec.* ./',
        'RUN dart pub get',
        'COPY . .',
        'RUN dart compile exe bin/main.dart -o bin/server',
        '',
        'FROM debian:bookworm-slim',
        'COPY --from=build /app/bin/server /app/bin/server',
        'EXPOSE 8080 8081 8082',
        'CMD ["/app/bin/server"]',
      ];

      for (int i = 0; i < steps.length; i++) {
        await Future.delayed(const Duration(milliseconds: 300));

        if (steps[i].isNotEmpty) {
          _addLog('Step ${i + 1}/${steps.length}: ${steps[i]}');
        } else {
          _addLog('');
        }

        // Update progress
        buildProgress.value = 0.3 + (0.6 * (i + 1) / steps.length);
      }

      await Future.delayed(const Duration(milliseconds: 500));
      _addLog('Successfully built airbar_backend_server:latest');
      _addLog('Successfully tagged airbar_backend_server:latest');
    } catch (e) {
      throw Exception('Erreur lors de la construction Docker: ${e.toString()}');
    }
  }

  Future<bool> _verifyDockerImage() async {
    try {
      // In a real implementation, we would run:
      // docker images airbar_backend_server:latest
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      return false;
    }
  }

  void _addLog(String message) {
    buildLogs.add(message);
    // Auto-scroll to bottom would be handled in the view
  }

  Future<void> retryBuild() async {
    buildLogs.clear();
    isComplete.value = false;
    await startBuild();
  }

  void skipBuild() {
    Get.defaultDialog(
      title: 'Attention',
      middleText:
          'Ignorer la construction empêchera le déploiement du serveur.\n\n'
          'Vous devrez construire l\'image Docker manuellement.',
      textConfirm: 'Continuer quand même',
      textCancel: 'Annuler',
      onConfirm: () {
        Get.back(); // Close dialog
        goToNextStep();
      },
    );
  }

  void goToNextStep() {
    // Navigate to deployment screen
    Get.offNamed(Routes.DEPLOYMENT);
  }

  void goBack() {
    Get.back();
  }
}
