import 'dart:io';
import 'package:get/get.dart';
import 'package:process_run/process_run.dart';
import '../core/constants/app_constants.dart';

enum CheckStatus { pending, checking, success, warning, error }

class SystemCheck {
  final String name;
  final String description;
  final Rx<CheckStatus> status;
  final RxString message;
  final bool isCritical;

  SystemCheck({
    required this.name,
    required this.description,
    this.isCritical = true,
  }) : status = CheckStatus.pending.obs,
       message = ''.obs;
}

class SystemCheckService extends GetxService {
  final checks = <SystemCheck>[].obs;
  final isChecking = false.obs;
  final hasErrors = false.obs;
  final hasCriticalErrors = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeChecks();
  }

  void _initializeChecks() {
    checks.value = [
      SystemCheck(
        name: 'Système d\'exploitation',
        description: 'Vérifie que Windows est compatible',
        isCritical: true,
      ),
      SystemCheck(
        name: 'Mémoire RAM',
        description:
            'Vérifie la mémoire disponible (min ${AppConstants.minRAMGB} GB)',
        isCritical: true,
      ),
      SystemCheck(
        name: 'Espace disque',
        description:
            'Vérifie l\'espace disponible (min ${AppConstants.minDiskSpaceGB} GB)',
        isCritical: true,
      ),
      SystemCheck(
        name: 'Droits administrateur',
        description: 'Vérifie les privilèges élevés',
        isCritical: true,
      ),
      SystemCheck(
        name: 'Connexion Internet',
        description: 'Vérifie la connectivité réseau',
        isCritical: false,
      ),
      SystemCheck(
        name: 'Docker Desktop',
        description: 'Vérifie si Docker est installé',
        isCritical: false,
      ),
      SystemCheck(
        name: 'Git',
        description: 'Vérifie si Git est installé',
        isCritical: false,
      ),
    ];
  }

  Future<void> runAllChecks() async {
    isChecking.value = true;
    hasErrors.value = false;
    hasCriticalErrors.value = false;

    await checkOS();
    await checkRAM();
    await checkDiskSpace();
    await checkAdminRights();
    await checkInternet();
    await checkDocker();
    await checkGit();

    // Update error flags
    hasErrors.value = checks.any((c) => c.status.value == CheckStatus.error);
    hasCriticalErrors.value = checks.any(
      (c) => c.isCritical && c.status.value == CheckStatus.error,
    );

    isChecking.value = false;
  }

  Future<void> checkOS() async {
    final check = checks.firstWhere((c) => c.name == 'Système d\'exploitation');
    check.status.value = CheckStatus.checking;

    try {
      if (!Platform.isWindows) {
        check.status.value = CheckStatus.error;
        check.message.value = 'Ce logiciel nécessite Windows';
        return;
      }

      // Get Windows version via PowerShell (wmic/pipe non supporté)
      final result = await Shell().run(
        'powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).Caption"',
      );
      final output = result.outText.trim();

      if (output.contains('Windows 10') ||
          output.contains('Windows 11') ||
          output.contains('Server')) {
        check.status.value = CheckStatus.success;
        check.message.value = output.isNotEmpty ? output : 'Windows compatible détecté';
      } else {
        check.status.value = CheckStatus.warning;
        check.message.value = 'Version Windows non testée';
      }
    } catch (e) {
      check.status.value = CheckStatus.warning;
      check.message.value = 'Impossible de détecter la version Windows';
    }
  }

  Future<void> checkRAM() async {
    final check = checks.firstWhere((c) => c.name == 'Mémoire RAM');
    check.status.value = CheckStatus.checking;

    try {
      final result = await Shell().run(
        'powershell -NoProfile -Command "(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory"',
      );
      final output = result.outText.trim();

      // Extract RAM value (in bytes)
      final match = RegExp(r'(\d+)').firstMatch(output);
      if (match != null) {
        final ramBytes = int.parse(match.group(1)!);
        final ramGB = ramBytes / (1024 * 1024 * 1024);

        if (ramGB >= AppConstants.minRAMGB) {
          check.status.value = CheckStatus.success;
          check.message.value = '${ramGB.toStringAsFixed(1)} GB disponible';
        } else {
          check.status.value = CheckStatus.error;
          check.message.value =
              'RAM insuffisante : ${ramGB.toStringAsFixed(1)} GB (requis: ${AppConstants.minRAMGB} GB)';
        }
      } else {
        check.status.value = CheckStatus.warning;
        check.message.value = 'Impossible de détecter la RAM';
      }
    } catch (e) {
      check.status.value = CheckStatus.warning;
      check.message.value = 'Erreur lors de la vérification: $e';
    }
  }

  Future<void> checkDiskSpace() async {
    final check = checks.firstWhere((c) => c.name == 'Espace disque');
    check.status.value = CheckStatus.checking;

    try {
      // Check C: drive space via PowerShell (wmic supprimé dans Windows 11 récent)
      final result = await Shell().run(
        'powershell -NoProfile -Command "(Get-PSDrive C).Free"',
      );
      final output = result.outText.trim();

      final match = RegExp(r'(\d+)').firstMatch(output);
      if (match != null) {
        final freeBytes = int.parse(match.group(1)!);
        final freeGB = freeBytes / (1024 * 1024 * 1024);

        if (freeGB >= AppConstants.minDiskSpaceGB) {
          check.status.value = CheckStatus.success;
          check.message.value =
              '${freeGB.toStringAsFixed(1)} GB disponible sur C:';
        } else {
          check.status.value = CheckStatus.error;
          check.message.value =
              'Espace insuffisant : ${freeGB.toStringAsFixed(1)} GB (requis: ${AppConstants.minDiskSpaceGB} GB)';
        }
      } else {
        check.status.value = CheckStatus.warning;
        check.message.value = 'Impossible de détecter l\'espace disque';
      }
    } catch (e) {
      check.status.value = CheckStatus.warning;
      check.message.value = 'Erreur: $e';
    }
  }

  Future<void> checkAdminRights() async {
    final check = checks.firstWhere((c) => c.name == 'Droits administrateur');
    check.status.value = CheckStatus.checking;

    try {
      // Vérification des droits admin via PowerShell
      final result = await Shell().run(
        'powershell -NoProfile -Command "([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)"',
      );
      final output = result.outText.trim().toLowerCase();

      if (output == 'true') {
        check.status.value = CheckStatus.success;
        check.message.value = 'Privilèges administrateur détectés';
      } else {
        check.status.value = CheckStatus.error;
        check.message.value = 'Veuillez relancer en tant qu\'administrateur';
      }
    } catch (e) {
      check.status.value = CheckStatus.error;
      check.message.value = 'Droits administrateur requis';
    }
  }

  Future<void> checkInternet() async {
    final check = checks.firstWhere((c) => c.name == 'Connexion Internet');
    check.status.value = CheckStatus.checking;

    try {
      final result = await Shell().run('ping -n 1 github.com');

      if (result.isNotEmpty && result.first.exitCode == 0) {
        check.status.value = CheckStatus.success;
        check.message.value = 'Connexion Internet active';
      } else {
        check.status.value = CheckStatus.warning;
        check.message.value = 'Pas de connexion Internet détectée';
      }
    } catch (e) {
      check.status.value = CheckStatus.warning;
      check.message.value = 'Connexion Internet non disponible';
    }
  }

  Future<void> checkDocker() async {
    final check = checks.firstWhere((c) => c.name == 'Docker Desktop');
    check.status.value = CheckStatus.checking;

    try {
      final result = await Shell().run('docker --version');

      if (result.isNotEmpty && result.first.exitCode == 0) {
        final version = result.first.outText.trim();
        check.status.value = CheckStatus.success;
        check.message.value = version;
      } else {
        check.status.value = CheckStatus.warning;
        check.message.value = 'Docker Desktop non installé';
      }
    } catch (e) {
      check.status.value = CheckStatus.warning;
      check.message.value = 'Docker Desktop non installé';
    }
  }

  Future<void> checkGit() async {
    final check = checks.firstWhere((c) => c.name == 'Git');
    check.status.value = CheckStatus.checking;

    try {
      final result = await Shell().run('git --version');

      if (result.isNotEmpty && result.first.exitCode == 0) {
        final version = result.first.outText.trim();
        check.status.value = CheckStatus.success;
        check.message.value = version;
      } else {
        check.status.value = CheckStatus.warning;
        check.message.value = 'Git non installé';
      }
    } catch (e) {
      check.status.value = CheckStatus.warning;
      check.message.value = 'Git non installé';
    }
  }

  String getCheckIcon(CheckStatus status) {
    switch (status) {
      case CheckStatus.pending:
        return '⏳';
      case CheckStatus.checking:
        return '🔄';
      case CheckStatus.success:
        return '✅';
      case CheckStatus.warning:
        return '⚠️';
      case CheckStatus.error:
        return '❌';
    }
  }
}
