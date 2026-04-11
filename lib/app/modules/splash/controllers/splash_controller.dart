import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../services/storage_service.dart';

class SplashController extends GetxController {
  final _storageService = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    _checkInstallationStatus();
  }

  Future<void> _checkInstallationStatus() async {
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 2));

    // Check if installation is already completed
    if (_storageService.isInstallationCompleted) {
      // Go to management dashboard
      Get.offAllNamed(Routes.MANAGEMENT_DASHBOARD);
    } else {
      // Go to welcome screen
      Get.offAllNamed(Routes.WELCOME);
    }
  }
}
