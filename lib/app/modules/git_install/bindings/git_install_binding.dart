import 'package:get/get.dart';
import '../controllers/git_install_controller.dart';

class GitInstallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GitInstallController>(
      () => GitInstallController(),
    );
  }
}
