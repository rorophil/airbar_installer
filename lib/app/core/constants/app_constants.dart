class AppConstants {
  // Storage Keys
  static const String keyInstallationCompleted = 'installation_completed';
  static const String keyInstallPath = 'install_path';
  static const String keyApiHost = 'api_host';
  static const String keyApiPort = 'api_port';
  static const String keyPostgresPassword = 'postgres_password';
  static const String keyRedisPassword = 'redis_password';

  // Default Values
  static const String defaultInstallPath = 'C:\\airbar_production';
  static const String defaultApiHost = 'localhost';
  static const int defaultApiPort = 8080;
  static const int defaultInsightsPort = 8081;
  static const int defaultWebPort = 8082;

  // System Requirements
  static const int minRAMGB = 8;
  static const int minDiskSpaceGB = 50;
  static const List<String> supportedOS = [
    'Windows 10',
    'Windows 11',
    'Windows Server',
  ];

  // GitHub
  static const String githubRepoURL =
      'https://github.com/rorophil/airbar_backend.git';
  static const String githubAPIURL =
      'https://api.github.com/repos/rorophil/airbar_backend';

  // Docker
  static const String dockerDesktopURL =
      'https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe';

  // Git
  static const String gitInstallerURL =
      'https://github.com/git-for-windows/git/releases/download/v2.45.0.windows.1/Git-2.45.0-64-bit.exe';

  // Timeouts
  static const Duration commandTimeout = Duration(minutes: 10);
  static const Duration downloadTimeout = Duration(minutes: 30);
  static const Duration dockerStartTimeout = Duration(minutes: 5);

  // Firewall Rules
  static const List<Map<String, dynamic>> firewallRules = [
    {'name': 'AirBar API Server', 'port': 8080},
    {'name': 'AirBar Insights Server', 'port': 8081},
    {'name': 'AirBar Web Server', 'port': 8082},
  ];
}
