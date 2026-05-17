import 'package:get/get.dart';
import '../../../services/storage_service.dart';
import '../../../routes/app_pages.dart';

class DeploymentController extends GetxController {
  final _storageService = Get.find<StorageService>();

  final isDeploying = false.obs;
  final deploymentProgress = 0.0.obs;
  final currentStep = ''.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isComplete = false.obs;

  // Deployment steps with status
  final deploymentSteps = <DeploymentStep>[].obs;

  String get installPath => _storageService.installPath ?? 'C:\\AirBar';
  String get serverPath => '$installPath\\airbar_backend_server';
  String get apiHost => _storageService.storage.read('api_host') ?? 'localhost';
  int get apiPort => _storageService.storage.read('api_port') ?? 8080;

  @override
  void onInit() {
    super.onInit();
    _initializeSteps();
    startDeployment();
  }

  void _initializeSteps() {
    deploymentSteps.value = [
      DeploymentStep(
        id: 'firewall',
        name: 'Configuration du pare-feu',
        description: 'Ouverture des ports 8080, 8081, 8082',
        status: StepStatus.pending,
      ),
      DeploymentStep(
        id: 'docker_compose',
        name: 'Démarrage des conteneurs',
        description: 'Lancement de PostgreSQL, Redis et AirBar Server',
        status: StepStatus.pending,
      ),
      DeploymentStep(
        id: 'database',
        name: 'Initialisation de la base de données',
        description: 'Création des tables et migrations',
        status: StepStatus.pending,
      ),
      DeploymentStep(
        id: 'health_check',
        name: 'Vérification des services',
        description: 'Test de connectivité des endpoints',
        status: StepStatus.pending,
      ),
    ];
  }

  Future<void> startDeployment() async {
    isDeploying.value = true;
    hasError.value = false;
    errorMessage.value = '';
    deploymentProgress.value = 0.0;

    try {
      // Step 1: Configure firewall
      await _executeStep(0, _configureFirewall);
      deploymentProgress.value = 0.25;

      // Step 2: Start Docker containers
      await _executeStep(1, _startDockerContainers);
      deploymentProgress.value = 0.5;

      // Step 3: Initialize database
      await _executeStep(2, _initializeDatabase);
      deploymentProgress.value = 0.75;

      // Step 4: Health check
      await _executeStep(3, _performHealthCheck);
      deploymentProgress.value = 1.0;

      isComplete.value = true;
      currentStep.value = 'Déploiement terminé !';

      // Auto-navigate to success screen after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      goToNextStep();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      currentStep.value = 'Erreur de déploiement';
    } finally {
      isDeploying.value = false;
    }
  }

  Future<void> _executeStep(int index, Future<void> Function() action) async {
    // Update step to in progress
    final step = deploymentSteps[index];
    deploymentSteps[index] = DeploymentStep(
      id: step.id,
      name: step.name,
      description: step.description,
      status: StepStatus.inProgress,
    );
    deploymentSteps.refresh();

    currentStep.value = step.name;

    try {
      await action();

      // Update step to success
      deploymentSteps[index] = DeploymentStep(
        id: step.id,
        name: step.name,
        description: step.description,
        status: StepStatus.success,
      );
    } catch (e) {
      // Update step to error
      deploymentSteps[index] = DeploymentStep(
        id: step.id,
        name: step.name,
        description: step.description,
        status: StepStatus.error,
        errorMessage: e.toString(),
      );
      throw e;
    } finally {
      deploymentSteps.refresh();
    }
  }

  Future<void> _configureFirewall() async {
    await Future.delayed(const Duration(seconds: 2));

    // Simulate firewall configuration
    // In real implementation:
    // PowerShell command to add firewall rules
    // New-NetFirewallRule -DisplayName "AirBar API" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
  }

  Future<void> _startDockerContainers() async {
    await Future.delayed(const Duration(seconds: 3));

    // Simulate docker-compose up -d
    // In real implementation:
    // cd $serverPath && docker-compose -f docker-compose.production.yaml up -d
  }

  Future<void> _initializeDatabase() async {
    await Future.delayed(const Duration(seconds: 2));

    // Simulate database initialization
    // Migrations are automatically applied by Serverpod on startup
  }

  Future<void> _performHealthCheck() async {
    await Future.delayed(const Duration(seconds: 1));

    // Simulate health check
    // In real implementation:
    // HTTP GET to http://$apiHost:$apiPort/health
    // HTTP GET to http://$apiHost:8081/
    // HTTP GET to http://$apiHost:8082/
  }

  Future<void> retryDeployment() async {
    _initializeSteps();
    isComplete.value = false;
    await startDeployment();
  }

  void skipDeployment() {
    Get.defaultDialog(
      title: 'Attention',
      middleText:
          'Ignorer le déploiement signifie que le serveur ne sera pas démarré.\n\n'
          'Vous devrez démarrer les services manuellement.',
      textConfirm: 'Continuer quand même',
      textCancel: 'Annuler',
      onConfirm: () {
        Get.back(); // Close dialog
        goToNextStep();
      },
    );
  }

  void goToNextStep() {
    // Navigate to success screen
    Get.offNamed(Routes.SUCCESS);
  }

  void goBack() {
    Get.back();
  }
}

class DeploymentStep {
  final String id;
  final String name;
  final String description;
  final StepStatus status;
  final String? errorMessage;

  DeploymentStep({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    this.errorMessage,
  });
}

enum StepStatus { pending, inProgress, success, error }
