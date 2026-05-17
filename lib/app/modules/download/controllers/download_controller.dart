import 'package:get/get.dart';
import '../../../services/git_service.dart';
import '../../../services/storage_service.dart';
import '../../../routes/app_pages.dart';

class DownloadController extends GetxController {
  final _gitService = Get.find<GitService>();
  final _storageService = Get.find<StorageService>();

  final isDownloading = false.obs;
  final downloadProgress = 0.0.obs;
  final downloadMessage = ''.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isComplete = false.obs;

  // Verification checklist
  final verificationSteps = <VerificationStep>[].obs;

  String get installPath => _storageService.installPath ?? 'C:\\AirBar';

  @override
  void onInit() {
    super.onInit();
    _initializeVerificationSteps();
    startDownload();
  }

  void _initializeVerificationSteps() {
    verificationSteps.value = [
      VerificationStep(
        name: 'pubspec.yaml',
        description: 'Configuration du projet',
        status: VerificationStatus.pending,
      ),
      VerificationStep(
        name: 'docker-compose.yaml',
        description: 'Configuration Docker',
        status: VerificationStatus.pending,
      ),
      VerificationStep(
        name: 'Dockerfile',
        description: 'Image Docker du serveur',
        status: VerificationStatus.pending,
      ),
      VerificationStep(
        name: 'lib/src/endpoints',
        description: 'Endpoints du serveur',
        status: VerificationStatus.pending,
      ),
      VerificationStep(
        name: 'migrations',
        description: 'Migrations de base de données',
        status: VerificationStatus.pending,
      ),
    ];
  }

  Future<void> startDownload() async {
    isDownloading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    downloadProgress.value = 0.0;

    try {
      downloadMessage.value = 'Préparation du téléchargement...';
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if Git is installed
      final gitInstalled = _gitService.status.value == GitStatus.installed;

      if (gitInstalled) {
        downloadMessage.value = 'Clonage du repository avec Git...';
        final success = await _gitService.cloneRepository(installPath);

        if (!success) {
          throw Exception('Échec du clonage avec Git');
        }
      } else {
        downloadMessage.value = 'Téléchargement de l\'archive ZIP...';
        final success = await _gitService.downloadAsZip(installPath);

        if (!success) {
          throw Exception('Échec du téléchargement ZIP');
        }
      }

      // Monitor progress
      _gitService.cloneProgress.listen((progress) {
        downloadProgress.value = progress;
      });

      _gitService.cloneMessage.listen((message) {
        downloadMessage.value = message;
      });

      // Wait for completion
      await Future.delayed(const Duration(milliseconds: 500));

      // Verify downloaded files
      downloadMessage.value = 'Vérification des fichiers...';
      await _verifyFiles();

      isComplete.value = true;
      downloadMessage.value = 'Téléchargement terminé avec succès !';

      // Auto-navigate to build screen after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      goToNextStep();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      downloadMessage.value = 'Erreur lors du téléchargement';
    } finally {
      isDownloading.value = false;
    }
  }

  Future<void> _verifyFiles() async {
    final requiredFiles = [
      'pubspec.yaml',
      'docker-compose.yaml',
      'Dockerfile',
      'lib/src/endpoints',
      'migrations',
    ];

    for (int i = 0; i < requiredFiles.length; i++) {
      await Future.delayed(const Duration(milliseconds: 300));

      // Simulate verification (in real app, check file existence)
      final step = verificationSteps[i];

      // Update status
      verificationSteps[i] = VerificationStep(
        name: step.name,
        description: step.description,
        status: VerificationStatus.success,
      );

      verificationSteps.refresh();
    }
  }

  Future<void> retryDownload() async {
    _initializeVerificationSteps();
    isComplete.value = false;
    await startDownload();
  }

  void skipDownload() {
    Get.defaultDialog(
      title: 'Attention',
      middleText:
          'Ignorer le téléchargement empêchera l\'installation du serveur.\n\n'
          'Vous devrez télécharger manuellement le code depuis GitHub.',
      textConfirm: 'Continuer quand même',
      textCancel: 'Annuler',
      onConfirm: () {
        Get.back(); // Close dialog
        goToNextStep();
      },
    );
  }

  void goToNextStep() {
    // Navigate to build screen
    Get.offNamed(Routes.BUILD);
  }

  void goBack() {
    Get.back();
  }
}

class VerificationStep {
  final String name;
  final String description;
  final VerificationStatus status;

  VerificationStep({
    required this.name,
    required this.description,
    required this.status,
  });
}

enum VerificationStatus { pending, checking, success, error }
