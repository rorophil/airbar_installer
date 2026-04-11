import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/values/app_colors.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tableau de bord AirBar'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          Obx(
            () => IconButton(
              icon: controller.isLoading.value
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh),
              onPressed: controller.isLoading.value
                  ? null
                  : controller.loadServicesStatus,
              tooltip: 'Actualiser',
            ),
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
              // Header with install info
              _buildHeaderCard(),

              SizedBox(height: 24.h),

              // Services status
              Text(
                'État des services',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: 16.h),

              Expanded(
                child: Obx(() {
                  if (controller.errorMessage.value.isNotEmpty) {
                    return _buildErrorCard();
                  }

                  if (controller.services.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    itemCount: controller.services.length,
                    itemBuilder: (context, index) {
                      final service = controller.services[index];
                      return _buildServiceCard(service);
                    },
                  );
                }),
              ),

              SizedBox(height: 24.h),

              // Management actions
              _buildManagementActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
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
                Icon(Icons.info_outline, size: 24.w, color: AppColors.primary),
                SizedBox(width: 12.w),
                Text(
                  'Informations d\'installation',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildInfoRow('Emplacement', controller.installPath),
            _buildInfoRow('Hôte API', controller.apiHost),
            _buildInfoRow('Port API', controller.apiPort.toString()),
            Obx(
              () => _buildInfoRow(
                'Dernière mise à jour',
                _formatDateTime(controller.lastUpdateTime.value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
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
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceInfo service) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (service.status) {
      case ServiceStatus.running:
        statusColor = AppColors.stepSuccess;
        statusIcon = Icons.check_circle;
        statusText = 'En cours d\'exécution';
        break;
      case ServiceStatus.stopped:
        statusColor = AppColors.stepError;
        statusIcon = Icons.cancel;
        statusText = 'Arrêté';
        break;
      case ServiceStatus.error:
        statusColor = AppColors.stepError;
        statusIcon = Icons.error;
        statusText = 'Erreur';
        break;
      case ServiceStatus.unknown:
        statusColor = AppColors.stepWarning;
        statusIcon = Icons.help_outline;
        statusText = 'Inconnu';
        break;
    }

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.w),
        side: BorderSide(color: statusColor.withOpacity(0.3), width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, size: 24.w, color: statusColor),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    service.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            if (service.containerId != null) ...[
              SizedBox(height: 12.h),
              Text(
                'ID: ${service.containerId!.substring(0, 12)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'monospace',
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (service.uptime != null ||
                service.cpuUsage != null ||
                service.memoryUsage != null) ...[
              SizedBox(height: 12.h),
              Row(
                children: [
                  if (service.uptime != null)
                    Expanded(
                      child: _buildMetricChip(
                        Icons.access_time,
                        service.uptime!,
                      ),
                    ),
                  if (service.cpuUsage != null) ...[
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildMetricChip(
                        Icons.memory,
                        'CPU: ${service.cpuUsage}',
                      ),
                    ),
                  ],
                  if (service.memoryUsage != null) ...[
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildMetricChip(
                        Icons.storage,
                        service.memoryUsage!,
                      ),
                    ),
                  ],
                ],
              ),
            ],
            if (service.status == ServiceStatus.running ||
                service.status == ServiceStatus.stopped) ...[
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (service.status == ServiceStatus.stopped)
                    TextButton.icon(
                      onPressed: () => controller.startService(service.name),
                      icon: Icon(Icons.play_arrow, size: 18.w),
                      label: const Text('Démarrer'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.stepSuccess,
                      ),
                    ),
                  if (service.status == ServiceStatus.running) ...[
                    TextButton.icon(
                      onPressed: () => controller.stopService(service.name),
                      icon: Icon(Icons.stop, size: 18.w),
                      label: const Text('Arrêter'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.stepError,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    TextButton.icon(
                      onPressed: () => controller.restartService(service.name),
                      icon: Icon(Icons.refresh, size: 18.w),
                      label: const Text('Redémarrer'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.w, color: AppColors.textSecondary),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      elevation: 2,
      color: AppColors.stepError.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.w),
        side: BorderSide(color: AppColors.stepError.withOpacity(0.3)),
      ),
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
            ElevatedButton.icon(
              onPressed: controller.loadServicesStatus,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64.w,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              'Aucun service trouvé',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Les services Docker ne semblent pas être en cours d\'exécution',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions de gestion',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: [
            _buildActionButton(
              'Logs',
              Icons.article_outlined,
              controller.goToLogs,
              AppColors.primary,
            ),
            _buildActionButton(
              'Sauvegardes',
              Icons.backup_outlined,
              controller.goToBackups,
              AppColors.stepSuccess,
            ),
            _buildActionButton(
              'Configuration',
              Icons.settings_outlined,
              controller.goToConfig,
              AppColors.stepWarning,
            ),
            _buildActionButton(
              'Mise à jour',
              Icons.system_update_outlined,
              controller.goToUpdate,
              AppColors.primary,
            ),
            _buildActionButton(
              'Désinstaller',
              Icons.delete_outline,
              controller.goToUninstall,
              AppColors.stepError,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
    Color color,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20.w),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w)),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
