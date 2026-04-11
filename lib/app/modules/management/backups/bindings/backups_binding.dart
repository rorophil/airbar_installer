import 'package:get/get.dart';
import '../controllers/backups_controller.dart';

class BackupsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BackupsController>(() => BackupsController());
  }
}
