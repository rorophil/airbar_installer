import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../services/git_service.dart';
import '../../../routes/app_pages.dart';

class GitInstallController extends GetxController {
  final _gitService = Get.find<GitService>();

  bool get isInstalled => _gitService.status.value == GitStatus.installed;
  bool get isInstalling => _gitService.isInstalling.value;
  bool get hasError => _gitService.status.value == GitStatus.error;
  double get progress => _gitService.installProgress.value;
  String get message => _gitService.installMessage.value;
  String get errorMsg => _gitService.errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    // Auto-start installation if Git not installed
    if (_gitService.status.value == GitStatus.notInstalled) {
      startInstallation();
    }
  }

  Future<void> startInstallation() async {
    final success = await _gitService.installGit();
    
    if (success) {
      // Auto-navigate to next step after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      goToNextStep();
    }
  }

  Future<void> retryInstallation() async {
    await _gitService.checkGitStatus();
    
    if (_gitService.status.value == GitStatus.notInstalled) {
      startInstallation();
    } else {
      goToNextStep();
    }
  }

  void skipInstallation() {
    Get.defaultDialog(
      title: 'Attention',
      middleText: 'Git est requis pour cloner le dépôt AirBar Backend.\n\n'
          'Sans Git, le téléchargement sera effectué en archive ZIP, ce qui peut être moins fiable.',
      textConfirm: 'Continuer sans Git',
      textCancel: 'Annuler',
      onConfirm: () {
        Get.back(); // Close dialog
        goToNextStep();
      },
    );
  }

  void goToNextStep() {
    // Go to configuration screen
    Get.offNamed(Routes.CONFIGURATION);
  }
}
