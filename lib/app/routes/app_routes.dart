part of 'app_pages.dart';

abstract class Routes {
  // Initialization
  static const SPLASH = '/splash';
  static const WELCOME = '/welcome';

  // Installation Steps
  static const SYSTEM_CHECK = '/system-check';
  static const DOCKER_INSTALL = '/docker-install';
  static const GIT_INSTALL = '/git-install';
  static const CONFIGURATION = '/configuration';
  static const DOWNLOAD = '/download';
  static const BUILD = '/build';
  static const DEPLOYMENT = '/deployment';
  static const SUCCESS = '/success';

  // Management routes (active)
  static const MANAGEMENT_DASHBOARD = '/management/dashboard';
  static const MANAGEMENT_LOGS = '/management/logs';
  static const MANAGEMENT_BACKUPS = '/management/backups';
  static const MANAGEMENT_CONFIG = '/management/config';
  static const MANAGEMENT_UPDATE = '/management/update';
  static const MANAGEMENT_UNINSTALL = '/management/uninstall';
}
