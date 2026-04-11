import 'package:get/get.dart';
import '../controllers/build_controller.dart';

class BuildBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BuildController>(() => BuildController());
  }
}
