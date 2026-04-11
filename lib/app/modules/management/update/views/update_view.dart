import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/values/app_colors.dart';
import '../controllers/update_controller.dart';

class UpdateView extends GetView<UpdateController> {
  const UpdateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mise à jour'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          Obx(
            () => IconButton(
              icon: const Icon(Icons.refresh),
              onPressed:
                  controller.status.value != UpdateStatus.updating &&
                      controller.status.value != UpdateStatus.downloading
                  ? controller.checkForUpdates
                  : null,
              tooltip: 'Vérifier les mises à jour',
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              _buildVersionCard(),
              SizedBox(height: 24.h),
              Expanded(child: _buildLogsSection()),
              SizedBox(height: 24.h),
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.system_update_outlined,
                  size: 24.w,
                  color: AppColors.primary,
                ),
                SizedBox(width: 12.w),
                Text(
                  'État de la mise à jour',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Obx(
              () => _buildVersionRow(
                'Version actuelle',
                controller.currentVersion.value.isEmpty
                    ? 'Vérification...'
                    : controller.currentVersion.value,
              ),
            ),
            SizedBox(height: 12.h),
            Obx(
              () => _buildVersionRow(
                'Dernière version',
                controller.latestVersion.value.isEmpty
                    ? 'Vérification...'
                    : controller.latestVersion.value,
              ),
            ),
            SizedBox(height: 20.h),
            Obx(() => _buildStatusIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (controller.status.value) {
      case UpdateStatus.checking:
        statusColor = AppColors.primary;
        statusIcon = Icons.sync;
        statusText = 'Vérification en cours...';
        break;
      case UpdateStatus.available:
        statusColor = AppColors.stepWarning;
        statusIcon = Icons.notification_important;
        statusText = 'Mise à jour disponible';
        break;
      case UpdateStatus.upToDate:
        statusColor = AppColors.stepSuccess;
        statusIcon = Icons.check_circle;
        statusText = 'À jour';
        break;
      case UpdateStatus.downloading:
        statusColor = AppColors.primary;
        statusIcon = Icons.cloud_download;
        statusText = 'Téléchargement...';
        break;
      case UpdateStatus.updating:
        statusColor = AppColors.primary;
        statusIcon = Icons.build;
        statusText = 'Installation en cours...';
        break;
      case UpdateStatus.error:
        statusColor = AppColors.stepError;
        statusIcon = Icons.error;
        statusText = 'Erreur';
        break;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.w),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, size: 24.w, color: statusColor),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Logs de mise à jour',
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
                child: Obx(() {
                  if (controller.updateLogs.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucun log disponible',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[400],
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: controller.updateLogs.map((log) {
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
                  );
                }),
              ),
            ),
            Obx(() {
              if (controller.status.value == UpdateStatus.downloading ||
                  controller.status.value == UpdateStatus.updating) {
                return Column(
                  children: [
                    SizedBox(height: 12.h),
                    LinearProgressIndicator(
                      value: controller.updateProgress.value,
                      backgroundColor: Colors.grey[200],
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '${(controller.updateProgress.value * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Obx(() {
      final status = controller.status.value;

      if (status == UpdateStatus.available) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.performUpdate,
            icon: Icon(Icons.system_update, size: 24.w),
            label: const Text('Installer la mise à jour'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.stepWarning,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 18.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.w),
              ),
            ),
          ),
        );
      }

      if (status == UpdateStatus.downloading ||
          status == UpdateStatus.updating) {
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
            label: Text(
              status == UpdateStatus.downloading
                  ? 'Téléchargement...'
                  : 'Installation...',
            ),
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
              disabledForegroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 18.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.w),
              ),
            ),
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }
}
