class AppStrings {
  // App
  static const String appName = 'AirBar Server Installer';
  static const String appTagLine = 'Assistant d\'installation pour Windows';

  // Installation Steps
  static const String stepSplash = 'Initialisation';
  static const String stepWelcome = 'Bienvenue';
  static const String stepSystemCheck = 'Vérifications système';
  static const String stepDocker = 'Installation Docker';
  static const String stepGit = 'Installation Git';
  static const String stepConfiguration = 'Configuration';
  static const String stepDownload = 'Téléchargement';
  static const String stepBuild = 'Construction';
  static const String stepDeploy = 'Déploiement';
  static const String stepSuccess = 'Installation terminée';

  // Welcome
  static const String welcomeTitle =
      'Bienvenue dans l\'assistant d\'installation AirBar Server';
  static const String welcomeDescription =
      'Cet assistant va vous guider à travers l\'installation complète du serveur AirBar en mode production sur Windows.';
  static const String installSimple = 'Installation Simple';
  static const String installAdvanced = 'Installation Avancée';
  static const String estimatedTime = 'Durée estimée : 15-30 minutes';

  // System Check
  static const String checkingSystem = 'Vérification du système...';
  static const String checkOS = 'Système d\'exploitation';
  static const String checkRAM = 'Mémoire RAM';
  static const String checkDisk = 'Espace disque';
  static const String checkAdmin = 'Droits administrateur';
  static const String checkInternet = 'Connexion Internet';
  static const String recheckSystem = 'Relancer les vérifications';

  // Docker
  static const String dockerInstalling =
      'Installation de Docker Desktop en cours...';
  static const String dockerDownloading = 'Téléchargement de Docker Desktop';
  static const String dockerRequired =
      'Docker Desktop est requis pour exécuter le serveur AirBar';

  // Configuration
  static const String installPath = 'Dossier d\'installation';
  static const String apiHost = 'Host API';
  static const String apiPort = 'Port API';
  static const String postgresPassword = 'Mot de passe PostgreSQL';
  static const String redisPassword = 'Mot de passe Redis';
  static const String generatePasswords = 'Générer nouveaux mots de passe';

  // Deployment
  static const String startingServices = 'Démarrage des services...';
  static const String configuringFirewall = 'Configuration du pare-feu...';
  static const String configuringBackups = 'Configuration des sauvegardes...';
  static const String runningTests = 'Tests de validation...';

  // Management
  static const String dashboard = 'Tableau de bord';
  static const String servicesStatus = 'État des services';
  static const String viewLogs = 'Voir les logs';
  static const String createBackup = 'Créer une sauvegarde';
  static const String startServices = 'Démarrer les services';
  static const String stopServices = 'Arrêter les services';
  static const String restartServices = 'Redémarrer les services';

  // Common
  static const String next = 'Suivant';
  static const String previous = 'Précédent';
  static const String finish = 'Terminer';
  static const String cancel = 'Annuler';
  static const String close = 'Fermer';
  static const String retry = 'Réessayer';
  static const String skip = 'Ignorer';
  static const String save = 'Enregistrer';
  static const String loading = 'Chargement...';
  static const String pleaseWait = 'Veuillez patienter...';

  // Success
  static const String installSuccess = 'Installation terminée avec succès !';
  static const String configSaved = 'Configuration enregistrée';
  static const String serviceStarted = 'Service démarré';
  static const String serviceStopped = 'Service arrêté';

  // Errors
  static const String errorGeneric = 'Une erreur est survenue';
  static const String errorAdmin = 'Droits administrateur requis';
  static const String errorDiskSpace = 'Espace disque insuffisant';
  static const String errorInternet = 'Connexion Internet requise';
  static const String errorDocker = 'Erreur lors de l\'installation de Docker';
}
