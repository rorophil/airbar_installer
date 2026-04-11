# Changelog - AirBar Installer

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

## [Non publié]

### À venir
- Authentification pour accès au dashboard de gestion
- Notifications pour mises à jour disponibles
- Logs plus détaillés avec niveaux (debug, info, warn, error)
- Support multi-langue (anglais)
- Mode sombre

## [1.0.0] - 2026-04-11

### Ajouté

#### Assistant d'Installation (10 écrans)
- **Splash**: Écran de démarrage avec logo et animation
- **Welcome**: Présentation de l'application et instructions
- **SystemCheck**: Vérification automatique des prérequis système
  - Windows version (10/11 64-bit)
  - Architecture système
  - RAM disponible (minimum 4GB)
  - Espace disque (minimum 10GB)
  - PowerShell version (5.1+)
  - Détection Docker Desktop
  - Détection Git for Windows
- **DockerInstall**: Installation automatique de Docker Desktop
  - Téléchargement depuis le site officiel
  - Installation silencieuse
  - Détection de l'installation existante
- **GitInstall**: Installation automatique de Git for Windows
  - Téléchargement depuis le site officiel
  - Installation avec paramètres par défaut
  - Détection de l'installation existante
- **Configuration**: Paramétrage du serveur
  - Choix du dossier d'installation (défaut: C:\AirBar)
  - Configuration hôte API (défaut: localhost)
  - Configuration ports (API: 8080, Insights: 8081, Web: 8082)
  - Validation des entrées
  - Génération automatique de mots de passe sécurisés (PostgreSQL, Redis)
- **Download**: Téléchargement du code source
  - Clone de airbar (frontend + client)
  - Clone de airbar_backend (serveur Serverpod)
  - Barre de progression
  - Gestion des erreurs réseau
- **Build**: Compilation du serveur
  - Installation des dépendances Dart
  - Génération du code Serverpod
  - Affichage des logs en temps réel
  - Estimation du temps restant
- **Deployment**: Déploiement en production
  - Création fichiers de configuration (.env, docker-compose, production.yaml)
  - Démarrage PostgreSQL (conteneur Docker)
  - Démarrage Redis (conteneur Docker)
  - Démarrage serveur AirBar (conteneur Docker)
  - Vérification de l'état des services
- **Success**: Résumé de l'installation
  - URLs d'accès (API, Insights, Web)
  - Résumé de la configuration
  - Accès direct au Dashboard de gestion

#### Dashboard de Gestion (6 modules)
- **Dashboard Principal**:
  - Vue d'ensemble de l'état des services
  - Statut API Server (vert/rouge)
  - Statut PostgreSQL (vert/rouge)
  - Statut Redis (vert/rouge)
  - Boutons contrôle: Démarrer, Arrêter, Redémarrer
  - Navigation latérale vers tous les modules
  
- **Module Logs**:
  - Visualisation en temps réel des logs du serveur
  - Rafraîchissement automatique (toutes les 5 secondes)
  - Bouton Pause/Reprendre
  - Export des logs vers fichier .txt
  - Horodatage des événements
  
- **Module Backups**:
  - Création manuelle de sauvegardes
  - Liste des sauvegardes disponibles avec dates
  - Restauration depuis une sauvegarde
  - Suppression de sauvegardes anciennes
  - Arrêt automatique des services avant sauvegarde/restauration
  
- **Module Config**:
  - Modification du dossier d'installation
  - Modification de l'hôte API
  - Modification des ports (API, Insights, Web)
  - Sauvegarde de la configuration
  - Redémarrage des services pour appliquer
  - Validation des entrées (ports valides, chemins existants)
  
- **Module Update**:
  - Vérification de nouvelles versions via Git
  - Affichage de la version actuelle
  - Mise à jour automatique (git pull)
  - Recompilation automatique après mise à jour
  - Redémarrage automatique des services
  - Bouton "Forcer la mise à jour"
  
- **Module Uninstall**:
  - Désinstallation guidée en plusieurs étapes
  - Options sélectionnables:
    - Supprimer Docker Desktop
    - Supprimer les données du serveur
    - Nettoyer les règles de pare-feu
  - Confirmations multiples (sécurité)
  - Arrêt et suppression des conteneurs Docker
  - Suppression des volumes Docker
  - Nettoyage du système de fichiers
  - Nettoyage des règles de pare-feu Windows

#### Services Backend
- **StorageService**: Persistance locale avec GetStorage
  - Sauvegarde état de l'installation
  - Sauvegarde configuration serveur
  - Cache des préférences utilisateur
  
- **SystemCheckService**: Vérifications système
  - Méthodes de détection OS, RAM, disque
  - Détection Docker Desktop (via docker --version)
  - Détection Git (via git --version)
  - Vérification PowerShell
  
- **DockerService**: Gestion Docker
  - Téléchargement Docker Desktop
  - Installation automatique
  - Commandes Docker (start, stop, restart containers)
  - Vérification état des conteneurs
  
- **GitService**: Gestion Git
  - Téléchargement Git for Windows
  - Installation automatique
  - Clone de repositories
  - Pull de mises à jour
  
- **ConfigurationService**: Génération configuration
  - Création fichier .env.production
  - Création docker-compose.production.yaml
  - Création config/production.yaml
  - Génération mots de passe sécurisés (32 caractères)

#### Scripts PowerShell
- **firewall-setup.ps1**: Configuration automatique du pare-feu Windows
  - Règles pour API Server (port configurable)
  - Règles pour Insights Server (port configurable)
  - Règles pour Web Server (port configurable)
  - Règles pour PostgreSQL (port 5432)
  - Règles pour Redis (port 6379)
  - Vérification privilèges administrateur
  
- **firewall-cleanup.ps1**: Nettoyage du pare-feu
  - Suppression de toutes les règles AirBar
  - Vérification privilèges administrateur
  
- **check-prerequisites.ps1**: Vérification prérequis
  - Windows version
  - Architecture 64-bit
  - Espace disque
  - RAM
  - PowerShell version
  - Connexion Internet
  - Droits administrateur

#### Packaging et Distribution
- **build.ps1**: Script de build automatique
  - Nettoyage builds précédents (optionnel)
  - Récupération dépendances Flutter
  - Analyse du code (flutter analyze)
  - Exécution des tests (optionnel)
  - Build Windows Release
  - Vérification fichiers de sortie
  - Vérification icône application
  - Compilation installateur Inno Setup (si disponible)
  
- **installer-setup.iss**: Configuration Inno Setup
  - Informations application (nom, version, éditeur)
  - Détection prérequis (via PowerShell)
  - Installation fichiers application
  - Installation scripts PowerShell
  - Installation documentation
  - Création raccourcis (bureau, menu démarrer)
  - Option autostart (optionnel)
  - Désinstallation avec nettoyage

#### Documentation
- **README.md**: Documentation principale du projet
  - Vue d'ensemble
  - Instructions installation
  - Guide de développement
  - Architecture technique
  - Procédure de build
  - Checklist de release
  
- **INSTALLATION_GUIDE.txt**: Guide installation utilisateur
  - Prérequis détaillés
  - Procédure pas à pas
  - Configuration serveur
  - Gestion quotidienne
  - Dépannage
  - FAQ
  
- **TESTING_GUIDE.txt**: Guide de test complet
  - Tests de build
  - Tests installateur
  - Tests assistant installation
  - Tests dashboard gestion
  - Tests de régression
  - Tests de stress
  - Critères de validation
  
- **LICENSE.txt**: Licence MIT
- **README.txt**: Readme court pour utilisateurs

#### Interface Utilisateur
- Design responsive avec FlutterScreenUtil
  - Taille de référence: 1280x720
  - Adaptation automatique à la résolution
  
- Thème moderne et cohérent
  - Couleur primaire: Bleu (#2196F3)
  - Couleur accent: Orange (#FF9800)
  - Cartes avec ombres portées
  - Animations de transition
  
- Gestion d'état réactive avec GetX
  - Variables observables (.obs)
  - Mise à jour automatique de l'UI
  - Navigation persistante
  
- Messages utilisateur clairs
  - Snackbars pour confirmations
  - Dialogues pour confirmations importantes
  - Messages d'erreur explicites

### Technique

#### Stack
- Flutter 3.x
- Dart 3.x
- GetX 4.6.5 (state management, routing, DI)
- GetStorage 2.1.1 (local storage)
- FlutterScreenUtil 5.9.0 (responsive UI)
- process_run 1.3.2 (PowerShell/CMD execution)

#### Architecture
- Pattern MVC (Model-View-Controller)
- Services singleton avec GetX
- Repositories pour abstraction données
- Bindings pour injection de dépendances
- Routes définies centralement

#### Configuration
- Ports par défaut: 8080 (API), 8081 (Insights), 8082 (Web)
- Dossier installation par défaut: C:\AirBar
- PostgreSQL dans Docker (port 5432)
- Redis dans Docker (port 6379)
- Mots de passe générés aléatoirement (32 caractères)

### Sécurité
- Génération mots de passe sécurisés (caractères spéciaux)
- Validation entrées utilisateur (ports, chemins)
- Confirmations multiples pour opérations destructives
- Gestion erreurs et exceptions
- Logs détaillés pour audit

### Performance
- Build optimisé en mode Release
- Cache des vérifications système
- Rafraîchissement intelligent des logs
- Opérations asynchrones (async/await)

## Notes de Migration

### Migration vers 1.0.0
Première version stable - Pas de migration nécessaire.

## Compatibilité

### Windows
- Windows 10 (64-bit) - ✅ Testé
- Windows 11 (64-bit) - ✅ Testé
- Windows Server 2019/2022 - ⚠️ Non testé officiellement

### Dépendances Externes
- Docker Desktop 4.x+ - Requis
- Git for Windows 2.x+ - Requis
- PowerShell 5.1+ - Requis
- Visual C++ Redistributable - Inclus dans installateur Flutter

## Remerciements

Merci à tous les contributeurs et aux équipes derrière:
- Flutter & Dart
- GetX
- Serverpod
- Docker
- PostgreSQL
- Redis
- Inno Setup

---

Pour plus d'informations, consultez:
- Repository: https://github.com/rorophil/airbar_installer
- Issues: https://github.com/rorophil/airbar_installer/issues
- Projet principal: https://github.com/rorophil/airbar
