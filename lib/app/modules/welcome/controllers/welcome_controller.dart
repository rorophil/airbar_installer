import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

enum InstallMode { simple, advanced }

class WelcomeController extends GetxController {
  final selectedMode = Rx<InstallMode?>(null);

  void selectMode(InstallMode mode) {
    selectedMode.value = mode;
  }

  void startInstallation() {
    if (selectedMode.value == null) {
      Get.snackbar(
        'Mode requis',
        'Veuillez sélectionner un mode d\'installation',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // TODO: Save selected mode to storage

    // Navigate to system check
    Get.toNamed(Routes.SYSTEM_CHECK);
  }

  void openDocumentation() {
    // TODO: Open documentation PDF or website
    Get.snackbar(
      'Documentation',
      'Ouverture de la documentation...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
