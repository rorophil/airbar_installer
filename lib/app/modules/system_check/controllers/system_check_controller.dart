import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../services/system_check_service.dart';

class SystemCheckController extends GetxController {
  final _systemCheckService = Get.find<SystemCheckService>();

  final isRunningChecks = false.obs;
  final canProceed = false.obs;

  @override
  void onInit() {
    super.onInit();
    _runChecks();
  }

  Future<void> _runChecks() async {
    isRunningChecks.value = true;
    await _systemCheckService.runAllChecks();
    isRunningChecks.value = false;

    // Can proceed only if no critical errors
    canProceed.value = !_systemCheckService.hasCriticalErrors.value;
  }

  Future<void> retryChecks() async {
    await _runChecks();
  }

  void proceedToNextStep() {
    if (!canProceed.value) {
      Get.snackbar(
        'Erreurs critiques',
        'Veuillez résoudre les erreurs critiques avant de continuer',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Check if Docker is installed
    final dockerCheck = _systemCheckService.checks.firstWhere(
      (c) => c.name == 'Docker Desktop',
    );

    if (dockerCheck.status.value != CheckStatus.success) {
      // Go to Docker installation
      Get.toNamed(Routes.DOCKER_INSTALL);
    } else {
      // Check if Git is installed
      final gitCheck = _systemCheckService.checks.firstWhere(
        (c) => c.name == 'Git',
      );

      if (gitCheck.status.value != CheckStatus.success) {
        // Go to Git installation
        Get.toNamed(Routes.GIT_INSTALL);
      } else {
        // Both installed, go to configuration
        Get.toNamed(Routes.CONFIGURATION);
      }
    }
  }
}
