import 'package:get/get.dart';
import '../controllers/docker_install_controller.dart';

class DockerInstallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DockerInstallController>(
      () => DockerInstallController(),
    );
  }
}
