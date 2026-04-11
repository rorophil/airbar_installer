# AirBar Installer

Application d'installation et de gestion pour le serveur AirBar - Solution de gestion de bar pour aéro-clubs.

## 📋 Vue d'Ensemble

AirBar Installer est une application Windows Flutter qui automatise le déploiement complet du serveur AirBar en mode production. Elle guide l'utilisateur à travers un processus d'installation en 10 étapes et fournit une interface de gestion complète.

### Fonctionnalités Principales

#### 🚀 Assistant d'Installation (10 écrans)
1. **Splash** - Écran de démarrage
2. **Welcome** - Présentation de l'application
3. **SystemCheck** - Vérification des prérequis système
4. **DockerInstall** - Installation automatique de Docker Desktop
5. **GitInstall** - Installation automatique de Git for Windows
6. **Configuration** - Configuration des ports et chemins d'installation
7. **Download** - Clonage des repositories GitHub
8. **Build** - Compilation du serveur Serverpod
9. **Deployment** - Déploiement des conteneurs Docker
10. **Success** - Résumé et URLs d'accès

#### 🎛️ Dashboard de Gestion (6 écrans)
1. **Dashboard** - Vue d'ensemble et contrôle des services
2. **Logs** - Visualisation des logs en temps réel
3. **Backups** - Gestion des sauvegardes
4. **Config** - Configuration du serveur
5. **Update** - Mises à jour automatiques
6. **Uninstall** - Désinstallation complète

## 🛠️ Prérequis de Développement

- **Flutter SDK**: 3.x ou supérieur
- **Dart SDK**: 3.x ou supérieur
- **Windows 10/11**: 64-bit
- **Visual Studio**: 2022 ou Build Tools (pour compilation Windows)
- **PowerShell**: 5.1 ou supérieur
- **Inno Setup**: 6.0 ou supérieur (pour créer l'installateur)

## 🚀 Développement

### Installation

```bash
# Cloner le repository
git clone https://github.com/rorophil/airbar_installer.git
cd airbar_installer

# Installer les dépendances
flutter pub get

# Vérifier l'installation
flutter doctor
```

### Exécution en Mode Debug

```bash
# Lancer sur Windows
flutter run -d windows

# Avec hot reload
flutter run -d windows --hot
```

### Tests

```bash
# Exécuter tous les tests
flutter test

# Analyse du code
flutter analyze
```

## 📦 Build et Packaging

### Build Manuel

```bash
# Build Windows Release
flutter build windows --release

# L'exécutable sera dans:
# build/windows/x64/runner/Release/airbar_installer.exe
```

### Build Automatique avec Script

```powershell
# Build complet avec installateur
.\build.ps1

# Build sans nettoyage préalable
.\build.ps1 -Clean:$false

# Build sans tests
.\build.ps1 -SkipTests

# Build application uniquement (sans installateur)
.\build.ps1 -BuildInstaller:$false
```

### Créer l'Installateur avec Inno Setup

**Option 1: Via le script de build**
```powershell
.\build.ps1
```

**Option 2: Manuellement**
1. Assurez-vous que l'application est compilée (`flutter build windows --release`)
2. Installez Inno Setup 6: https://jrsoftware.org/isdl.php
3. Ouvrez `installer-setup.iss` avec Inno Setup
4. Cliquez sur `Build` > `Compile`
5. L'installateur sera créé dans `build/windows/installer/`

## 🎨 Architecture Technique

### Stack
- **Framework**: Flutter 3.x
- **State Management**: GetX 4.6.5
- **Storage**: GetStorage 2.1.1
- **UI Responsive**: FlutterScreenUtil 5.9.0
- **Process Execution**: process_run 1.3.2

### Pattern
- **Architecture**: MVC (Model-View-Controller)
- **Routing**: GetX Navigation 2.0
- **Dependency Injection**: GetX Bindings
- **State**: Reactive (.obs)

### Services
- **StorageService**: Persistance locale (preferences, état installation)
- **SystemCheckService**: Vérification système (OS, RAM, disk, Docker, Git)
- **DockerService**: Installation et gestion Docker Desktop
- **GitService**: Installation et gestion Git for Windows
- **ConfigurationService**: Génération fichiers de configuration (.env, docker-compose, production.yaml)

## 🔧 Configuration

### Ports par Défaut
- **API Server**: 8080
- **Insights Server**: 8081
- **Web Server**: 8082
- **PostgreSQL**: 5432
- **Redis**: 6379

### Chemins par Défaut
- **Installation**: `C:\AirBar`
- **Serveur**: `C:\AirBar\airbar_backend\airbar_backend_server`

## 📚 Documentation

- [Documentation AirBar](https://github.com/rorophil/airbar/tree/main/information)
- [Documentation Serverpod](https://serverpod.dev/)
- [Documentation Flutter](https://flutter.dev/)
- [Documentation GetX](https://pub.dev/packages/get)
- [Documentation Inno Setup](https://jrsoftware.org/ishelp/)

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🙋 Support

Pour toute question ou problème:
- **Issues GitHub**: https://github.com/rorophil/airbar/issues
- **Documentation complète**: Dans `assets/docs/INSTALLATION_GUIDE.txt`

## ✅ Checklist de Release

- [ ] Tous les tests passent (`flutter test`)
- [ ] Aucune erreur d'analyse (`flutter analyze`)
- [ ] Version mise à jour dans `pubspec.yaml`
- [ ] Version mise à jour dans `installer-setup.iss`
- [ ] Icône créée (`assets/images/app_icon.ico`)
- [ ] Documentation à jour
- [ ] Build Windows réussit (`flutter build windows --release`)
- [ ] Installateur créé et testé
- [ ] Changelog mis à jour

## 📝 Notes de Version

### Version 1.0.0 (Avril 2026)
- ✅ Assistant d'installation complet (10 écrans)
- ✅ Dashboard de gestion (6 écrans)
- ✅ Installation automatique Docker et Git
- ✅ Configuration du pare-feu Windows
- ✅ Système de sauvegardes
- ✅ Mises à jour automatiques
- ✅ Désinstallation complète
- ✅ Installateur Inno Setup

---

**Développé avec ❤️ pour la communauté des aéro-clubs**
