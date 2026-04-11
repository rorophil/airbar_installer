import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/values/app_colors.dart';
import '../controllers/uninstall_controller.dart';

class UninstallView extends GetView<UninstallController> {
  const UninstallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Désinstallation'),
        backgroundColor: AppColors.stepError,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              // Warning card
              _buildWarningCard(),

              SizedBox(height: 24.h),

              // Options
              _buildOptionsSection(),

              SizedBox(height: 24.h),

              // Steps or logs
              Expanded(
                child: Obx(() {
                  if (controller.isUninstalling.value) {
                    return _buildUninstallProgress();
                  }
                  return _buildStepsList();
                }),
              ),

              SizedBox(height: 24.h),

              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningCard() {
    return Card(
      elevation: 2,
      color: AppColors.stepError.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.w),
        side: BorderSide(color: AppColors.stepError.withOpacity(0.3), width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Icon(Icons.warning_amber, size: 48.w, color: AppColors.stepError),
            SizedBox(height: 12.h),
            Text(
              'Attention !',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'La désinstallation supprimera tous les services et fichiers AirBar de votre système.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 8.h),
            Text(
              'Cette action est irréversible !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.stepError,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Options de désinstallation',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            Obx(
              () => CheckboxListTile(
                title: const Text('Supprimer toutes les données'),
                subtitle: const Text('Base de données et fichiers utilisateur'),
                value: controller.removeData.value,
                onChanged: (value) =>
                    controller.removeData.value = value ?? true,
                activeColor: AppColors.stepError,
              ),
            ),
            Obx(
              () => CheckboxListTile(
                title: const Text('Supprimer les sauvegardes'),
                subtitle: const Text('Toutes les sauvegardes seront perdues'),
                value: controller.removeBackups.value,
                onChanged: (value) =>
                    controller.removeBackups.value = value ?? false,
                activeColor: AppColors.stepError,
              ),
            ),
            Obx(
              () => CheckboxListTile(
                title: const Text('Désinstaller Docker'),
                subtitle: const Text(
                  'Désinstaller Docker Desktop (si installé par AirBar)',
                ),
                value: controller.removeDocker.value,
                onChanged: (value) =>
                    controller.removeDocker.value = value ?? false,
                activeColor: AppColors.stepError,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Étapes de désinstallation',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.builder(
                itemCount: controller.steps.length,
                itemBuilder: (context, index) {
                  final step = controller.steps[index];
                  return _buildStepItem(index + 1, step);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(int number, UninstallStep step) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.stepError.withOpacity(0.2),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.stepError,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  step.description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUninstallProgress() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Désinstallation en cours...',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            Obx(
              () => LinearProgressIndicator(
                value: controller.uninstallProgress.value,
                backgroundColor: Colors.grey[200],
                color: AppColors.stepError,
              ),
            ),
            SizedBox(height: 8.h),
            Obx(
              () => Text(
                '${(controller.uninstallProgress.value * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Logs',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8.w),
                ),
                child: Obx(
                  () => SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: controller.uninstallLogs.map((log) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 4.h),
                          child: Text(
                            log,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[300],
                              fontFamily: 'monospace',
                              height: 1.4,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Obx(() {
      final isUninstalling = controller.isUninstalling.value;

      if (isUninstalling) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: null,
            icon: SizedBox(
              width: 20.w,
              height: 20.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            label: const Text('Désinstallation en cours...'),
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: AppColors.stepError.withOpacity(0.6),
              disabledForegroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 18.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.w),
              ),
            ),
          ),
        );
      }

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showConfirmationDialog(),
          icon: Icon(Icons.delete_forever, size: 24.w),
          label: const Text('Désinstaller AirBar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.stepError,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 18.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.w),
            ),
          ),
        ),
      );
    });
  }

  void _showConfirmationDialog() {
    Get.defaultDialog(
      title: 'Confirmer la désinstallation',
      titleStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
      middleText:
          'Êtes-vous absolument sûr de vouloir désinstaller AirBar ?\n\nCette action est irréversible et supprimera tous les services et fichiers.',
      middleTextStyle: TextStyle(fontSize: 14.sp),
      textCancel: 'Annuler',
      textConfirm: 'Désinstaller',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.stepError,
      onConfirm: () {
        Get.back();
        controller.performUninstall();
      },
    );
  }
}
