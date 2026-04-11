import 'package:get/get.dart';
import '../controllers/uninstall_controller.dart';

class UninstallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UninstallController>(() => UninstallController());
  }
}
