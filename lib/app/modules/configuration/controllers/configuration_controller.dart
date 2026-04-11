import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../services/storage_service.dart';
import '../../../services/configuration_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../routes/app_pages.dart';

class ConfigurationController extends GetxController {
  final _storageService = Get.find<StorageService>();
  final _configService = Get.find<ConfigurationService>();

  // Form controllers
  final installPathController = TextEditingController();
  final apiHostController = TextEditingController();
  final apiPortController = TextEditingController();
  final insightsPortController = TextEditingController();
  final webPortController = TextEditingController();

  // Observable values
  final isAdvancedMode = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Use passwords from ConfigurationService
  String get postgresPassword => _configService.postgresPassword.value;
  String get redisPassword => _configService.redisPassword.value;

  // Form validation
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _loadDefaultValues();
    _generatePasswords();
  }

  @override
  void onClose() {
    installPathController.dispose();
    apiHostController.dispose();
    apiPortController.dispose();
    insightsPortController.dispose();
    webPortController.dispose();
    super.onClose();
  }

  void _loadDefaultValues() {
    // Check if user selected advanced mode from storage
    final mode = _storageService.storage.read('install_mode');
    isAdvancedMode.value = mode == 'advanced';

    // Load default values
    installPathController.text = AppConstants.defaultInstallPath;
    apiHostController.text = AppConstants.defaultApiHost;
    apiPortController.text = AppConstants.defaultApiPort.toString();
    insightsPortController.text = AppConstants.defaultInsightsPort.toString();
    webPortController.text = AppConstants.defaultWebPort.toString();
  }

  void _generatePasswords() {
    _configService.generatePasswords();
  }

  void copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copié',
      '\$label copié dans le presse-papiers',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  String? validatePath(String? value) {
    if (value == null || value.isEmpty) {
      return "Veuillez entrer un chemin d'installation";
    }
    // Basic Windows path validation
    if (!RegExp(r'^[A-Za-z]:\\').hasMatch(value)) {
      return "Le chemin doit être un chemin Windows valide (ex: C:\\AirBar)";
    }
    return null;
  }

  String? validateHost(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un hôte';
    }
    // Allow localhost, IP addresses, or domain names
    if (!RegExp(
      r'^(localhost|(\d{1,3}\.){3}\d{1,3}|[a-zA-Z0-9.-]+)$',
    ).hasMatch(value)) {
      return 'Hôte invalide (ex: localhost, 192.168.1.100)';
    }
    return null;
  }

  String? validatePort(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un port';
    }
    final port = int.tryParse(value);
    if (port == null || port < 1 || port > 65535) {
      return 'Port invalide (1-65535)';
    }
    return null;
  }

  Future<void> saveAndContinue() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Save configuration to storage
      _storageService.saveInstallConfig(
        installPath: installPathController.text,
        apiHost: apiHostController.text,
        apiPort: int.parse(apiPortController.text),
        insightsPort: int.parse(insightsPortController.text),
        webPort: int.parse(webPortController.text),
        postgresPassword: postgresPassword,
        redisPassword: redisPassword,
      );

      // Navigate to download screen
      Get.offNamed(Routes.DOWNLOAD);
    } catch (e) {
      errorMessage.value = 'Erreur lors de la sauvegarde: \${e.toString()}';
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goBack() {
    Get.back();
  }
}
