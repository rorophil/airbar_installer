import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../services/docker_service.dart';
import '../../../routes/app_pages.dart';

class DockerInstallController extends GetxController {
  final _dockerService = Get.find<DockerService>();

  bool get isInstalled => _dockerService.status.value == DockerStatus.installed ||
                         _dockerService.status.value == DockerStatus.running;
  bool get isInstalling => _dockerService.isInstalling.value;
  bool get hasError => _dockerService.status.value == DockerStatus.error;
  double get progress => _dockerService.installProgress.value;
  String get message => _dockerService.installMessage.value;
  String get errorMsg => _dockerService.errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    // Auto-start installation if Docker not installed
    if (_dockerService.status.value == DockerStatus.notInstalled) {
      startInstallation();
    }
  }

  Future<void> startInstallation() async {
    final success = await _dockerService.installDocker();
    
    if (success) {
      // Wait for Docker daemon to start
      await _dockerService.waitForDockerDaemon();
      
      // Check final status
      if (_dockerService.status.value == DockerStatus.running) {
        // Auto-navigate to next step after 2 seconds
        await Future.delayed(const Duration(seconds: 2));
        goToNextStep();
      }
    }
  }

  Future<void> retryInstallation() async {
    await _dockerService.checkDockerStatus();
    
    if (_dockerService.status.value == DockerStatus.notInstalled) {
      startInstallation();
    } else {
      goToNextStep();
    }
  }

  void skipInstallation() {
    Get.defaultDialog(
      title: 'Attention',
      middleText: 'Docker Desktop est requis pour exécuter AirBar Server.\n\n'
          'Vous devrez installer Docker manuellement avant de pouvoir déployer le serveur.',
      textConfirm: 'Continuer quand même',
      textCancel: 'Annuler',
      onConfirm: () {
        Get.back(); // Close dialog
        goToNextStep();
      },
    );
  }

  void goToNextStep() {
    // Check if Git is installed, if not go to Git install screen
    Get.offNamed(Routes.GIT_INSTALL);
  }
}
