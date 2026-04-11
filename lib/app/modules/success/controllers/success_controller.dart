import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/storage_service.dart';

class SuccessController extends GetxController {
  final _storageService = Get.find<StorageService>();

  String get installPath =>
      _storageService.storage.read('install_path') ?? 'C:\\AirBar';
  String get apiHost => _storageService.storage.read('api_host') ?? 'localhost';
  int get apiPort => _storageService.storage.read('api_port') ?? 8080;
  int get insightsPort => _storageService.storage.read('insights_port') ?? 8082;
  int get webPort => _storageService.storage.read('web_port') ?? 8081;

  String get apiUrl => 'http://$apiHost:$apiPort';
  String get webUrl => 'http://$apiHost:$webPort';
  String get insightsUrl => 'http://$apiHost:$insightsPort';

  void copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copié',
      '$label copié dans le presse-papiers',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  void openInBrowser(String url) {
    // In real implementation, use url_launcher package
    Get.snackbar(
      'Navigation',
      'Ouverture de $url dans le navigateur',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void finish() {
    // Mark installation as completed
    _storageService.storage.write('installation_completed', true);
    _storageService.storage.write(
      'installation_date',
      DateTime.now().toIso8601String(),
    );

    // Exit application or go to management dashboard
    Get.offAllNamed('/');
  }
}
