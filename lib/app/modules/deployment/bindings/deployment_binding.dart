import 'package:get/get.dart';
import '../controllers/deployment_controller.dart';

class DeploymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeploymentController>(() => DeploymentController());
  }
}
