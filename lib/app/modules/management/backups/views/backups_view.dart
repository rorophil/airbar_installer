import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/values/app_colors.dart';
import '../controllers/backups_controller.dart';

class BackupsView extends GetView<BackupsController> {
  const BackupsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sauvegardes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadBackups,
            tooltip: 'Actualiser',
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Create backup buttons
              _buildCreateBackupSection(),

              SizedBox(height: 24.h),

              // Backups list header
              Text(
                'Sauvegardes disponibles',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: 16.h),

              // Backups list
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.backups.isEmpty) {
                    return _buildLoadingState();
                  }

                  if (controller.errorMessage.value.isNotEmpty) {
                    return _buildErrorState();
                  }

                  if (controller.backups.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    itemCount: controller.backups.length,
                    itemBuilder: (context, index) {
                      final backup = controller.backups[index];
                      return _buildBackupCard(backup);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateBackupSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.backup, size: 24.w, color: AppColors.primary),
                SizedBox(width: 12.w),
                Text(
                  'Créer une sauvegarde',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Obx(() {
              if (controller.isCreatingBackup.value) {
                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: controller.backupProgress.value,
                      backgroundColor: Colors.grey[200],
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Création en cours... ${(controller.backupProgress.value * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          controller.createBackup(fullBackup: false),
                      icon: Icon(Icons.storage, size: 20.w),
                      label: const Text('Sauvegarde BDD'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          controller.createBackup(fullBackup: true),
                      icon: Icon(Icons.backup_outlined, size: 20.w),
                      label: const Text('Sauvegarde complète'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.stepSuccess,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupCard(BackupInfo backup) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    Color typeColor;
    IconData typeIcon;
    String typeLabel;

    if (backup.type == 'full') {
      typeColor = AppColors.stepSuccess;
      typeIcon = Icons.backup_outlined;
      typeLabel = 'Complète';
    } else {
      typeColor = AppColors.primary;
      typeIcon = Icons.storage;
      typeLabel = 'Base de données';
    }

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(typeIcon, size: 24.w, color: typeColor),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        backup.filename,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        dateFormat.format(backup.createdAt),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  child: Text(
                    typeLabel,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: typeColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 16.w,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Taille: ${backup.formattedSize}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => controller.exportBackup(backup),
                  icon: Icon(Icons.file_download, size: 18.w),
                  label: const Text('Exporter'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
                SizedBox(width: 8.w),
                TextButton.icon(
                  onPressed: () => _showRestoreConfirmation(backup),
                  icon: Icon(Icons.restore, size: 18.w),
                  label: const Text('Restaurer'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.stepWarning,
                  ),
                ),
                SizedBox(width: 8.w),
                TextButton.icon(
                  onPressed: () => _showDeleteConfirmation(backup),
                  icon: Icon(Icons.delete_outline, size: 18.w),
                  label: const Text('Supprimer'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.stepError,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16.h),
          Text(
            'Chargement des sauvegardes...',
            style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.w, color: AppColors.stepError),
            SizedBox(height: 16.h),
            Text(
              'Erreur',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Obx(
              () => Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: controller.loadBackups,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.backup_outlined,
            size: 64.w,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            'Aucune sauvegarde',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Créez votre première sauvegarde pour protéger vos données',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showRestoreConfirmation(BackupInfo backup) {
    Get.defaultDialog(
      title: 'Confirmer la restauration',
      titleStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
      middleText:
          'Êtes-vous sûr de vouloir restaurer cette sauvegarde ?\n\nCette action arrêtera le serveur et remplacera toutes les données actuelles.',
      middleTextStyle: TextStyle(fontSize: 14.sp),
      textCancel: 'Annuler',
      textConfirm: 'Restaurer',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.stepWarning,
      onConfirm: () {
        Get.back();
        controller.restoreBackup(backup);
      },
    );
  }

  void _showDeleteConfirmation(BackupInfo backup) {
    Get.defaultDialog(
      title: 'Confirmer la suppression',
      titleStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
      middleText:
          'Êtes-vous sûr de vouloir supprimer cette sauvegarde ?\n\nCette action est irréversible.',
      middleTextStyle: TextStyle(fontSize: 14.sp),
      textCancel: 'Annuler',
      textConfirm: 'Supprimer',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.stepError,
      onConfirm: () {
        Get.back();
        controller.deleteBackup(backup);
      },
    );
  }
}
