import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';
import '../../../../services/storage_service.dart';
import '../../../../services/configuration_service.dart';

class ConfigController extends GetxController {
  final _storageService = Get.find<StorageService>();
  final _configService = Get.find<ConfigurationService>();
  final _shell = Shell();

  // Form controllers
  final apiHostController = TextEditingController();
  final apiPortController = TextEditingController();
  final webPortController = TextEditingController();
  final insightsPortController = TextEditingController();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;
  final hasChanges = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentConfig();

    // Watch for changes
    apiHostController.addListener(() => hasChanges.value = true);
    apiPortController.addListener(() => hasChanges.value = true);
    webPortController.addListener(() => hasChanges.value = true);
    insightsPortController.addListener(() => hasChanges.value = true);
  }

  @override
  void onClose() {
    apiHostController.dispose();
    apiPortController.dispose();
    webPortController.dispose();
    insightsPortController.dispose();
    super.onClose();
  }

  void loadCurrentConfig() {
    try {
      isLoading.value = true;

      apiHostController.text =
          _storageService.storage.read('api_host') ?? 'localhost';
      apiPortController.text =
          (_storageService.storage.read('api_port') ?? 8080).toString();
      webPortController.text =
          (_storageService.storage.read('web_port') ?? 8081).toString();
      insightsPortController.text =
          (_storageService.storage.read('insights_port') ?? 8082).toString();

      hasChanges.value = false;
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveConfiguration() async {
    try {
      isSaving.value = true;
      errorMessage.value = '';

      // Validate inputs
      if (apiHostController.text.trim().isEmpty) {
        throw Exception('L\'hôte API ne peut pas être vide');
      }

      final apiPort = int.tryParse(apiPortController.text);
      if (apiPort == null || apiPort < 1 || apiPort > 65535) {
        throw Exception('Port API invalide');
      }

      final webPort = int.tryParse(webPortController.text);
      if (webPort == null || webPort < 1 || webPort > 65535) {
        throw Exception('Port Web invalide');
      }

      final insightsPort = int.tryParse(insightsPortController.text);
      if (insightsPort == null || insightsPort < 1 || insightsPort > 65535) {
        throw Exception('Port Insights invalide');
      }

      // Save to storage
      _storageService.storage.write('api_host', apiHostController.text.trim());
      _storageService.storage.write('api_port', apiPort);
      _storageService.storage.write('web_port', webPort);
      _storageService.storage.write('insights_port', insightsPort);

      // Regenerate configuration files
      final installPath =
          _storageService.storage.read('install_path') ?? 'C:\\AirBar';

      await _configService.createConfigurationFiles(
        installPath: installPath,
        apiHost: apiHostController.text.trim(),
        apiPort: apiPort,
        insightsPort: insightsPort,
        webPort: webPort,
      );

      hasChanges.value = false;

      Get.snackbar(
        'Configuration sauvegardée',
        'Les modifications ont été enregistrées avec succès.\nRedémarrez les services pour appliquer les changements.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> restartServices() async {
    try {
      isLoading.value = true;

      Get.snackbar(
        'Redémarrage',
        'Redémarrage des services en cours...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      // Restart Docker containers
      await _shell.run('docker-compose restart');

      Get.snackbar(
        'Services redémarrés',
        'Les services ont été redémarrés avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors du redémarrage: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resetToDefaults() {
    apiHostController.text = 'localhost';
    apiPortController.text = '8080';
    webPortController.text = '8081';
    insightsPortController.text = '8082';
    hasChanges.value = true;
  }

  bool validatePort(String value) {
    final port = int.tryParse(value);
    return port != null && port >= 1 && port <= 65535;
  }

  bool validateHost(String value) {
    if (value.trim().isEmpty) return false;

    // Check if it's 'localhost' or a valid IP pattern
    if (value == 'localhost') return true;

    final ipPattern = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );

    return ipPattern.hasMatch(value);
  }
}
