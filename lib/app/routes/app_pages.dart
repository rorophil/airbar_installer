import 'package:get/get.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/welcome/bindings/welcome_binding.dart';
import '../modules/welcome/views/welcome_view.dart';
import '../modules/system_check/bindings/system_check_binding.dart';
import '../modules/system_check/views/system_check_view.dart';
import '../modules/docker_install/bindings/docker_install_binding.dart';
import '../modules/docker_install/views/docker_install_view.dart';
import '../modules/git_install/bindings/git_install_binding.dart';
import '../modules/git_install/views/git_install_view.dart';
import '../modules/configuration/bindings/configuration_binding.dart';
import '../modules/configuration/views/configuration_view.dart';
import '../modules/download/bindings/download_binding.dart';
import '../modules/download/views/download_view.dart';
import '../modules/build/bindings/build_binding.dart';
import '../modules/build/views/build_view.dart';
import '../modules/deployment/bindings/deployment_binding.dart';
import '../modules/deployment/views/deployment_view.dart';
import '../modules/success/bindings/success_binding.dart';
import '../modules/success/views/success_view.dart';
import '../modules/management/dashboard/bindings/dashboard_binding.dart';
import '../modules/management/dashboard/views/dashboard_view.dart';
import '../modules/management/logs/bindings/logs_binding.dart';
import '../modules/management/logs/views/logs_view.dart';
import '../modules/management/backups/bindings/backups_binding.dart';
import '../modules/management/backups/views/backups_view.dart';
import '../modules/management/config/bindings/config_binding.dart';
import '../modules/management/config/views/config_view.dart';
import '../modules/management/update/bindings/update_binding.dart';
import '../modules/management/update/views/update_view.dart';
import '../modules/management/uninstall/bindings/uninstall_binding.dart';
import '../modules/management/uninstall/views/uninstall_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.WELCOME,
      page: () => const WelcomeView(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: Routes.SYSTEM_CHECK,
      page: () => const SystemCheckView(),
      binding: SystemCheckBinding(),
    ),
    GetPage(
      name: Routes.DOCKER_INSTALL,
      page: () => const DockerInstallView(),
      binding: DockerInstallBinding(),
    ),
    GetPage(
      name: Routes.GIT_INSTALL,
      page: () => const GitInstallView(),
      binding: GitInstallBinding(),
    ),
    GetPage(
      name: Routes.CONFIGURATION,
      page: () => const ConfigurationView(),
      binding: ConfigurationBinding(),
    ),
    GetPage(
      name: Routes.DOWNLOAD,
      page: () => const DownloadView(),
      binding: DownloadBinding(),
    ),
    GetPage(
      name: Routes.BUILD,
      page: () => const BuildView(),
      binding: BuildBinding(),
    ),
    GetPage(
      name: Routes.DEPLOYMENT,
      page: () => const DeploymentView(),
      binding: DeploymentBinding(),
    ),
    GetPage(
      name: Routes.SUCCESS,
      page: () => const SuccessView(),
      binding: SuccessBinding(),
    ),
    GetPage(
      name: Routes.MANAGEMENT_DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.MANAGEMENT_LOGS,
      page: () => const LogsView(),
      binding: LogsBinding(),
    ),
    GetPage(
      name: Routes.MANAGEMENT_BACKUPS,
      page: () => const BackupsView(),
      binding: BackupsBinding(),
    ),
    GetPage(
      name: Routes.MANAGEMENT_CONFIG,
      page: () => const ConfigView(),
      binding: ConfigBinding(),
    ),
    GetPage(
      name: Routes.MANAGEMENT_UPDATE,
      page: () => const UpdateView(),
      binding: UpdateBinding(),
    ),
    GetPage(
      name: Routes.MANAGEMENT_UNINSTALL,
      page: () => const UninstallView(),
      binding: UninstallBinding(),
    ),
  ];
}
