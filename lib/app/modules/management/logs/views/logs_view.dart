import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/values/app_colors.dart';
import '../controllers/logs_controller.dart';

class LogsView extends GetView<LogsController> {
  const LogsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Logs des services'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                controller.autoRefresh.value
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
              ),
              onPressed: controller.toggleAutoRefresh,
              tooltip: controller.autoRefresh.value
                  ? 'Désactiver le rafraîchissement automatique'
                  : 'Activer le rafraîchissement automatique',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: controller.exportLogs,
            tooltip: 'Exporter les logs',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearConfirmation(context),
            tooltip: 'Effacer les logs',
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top controls
            _buildControls(),

            // Logs display
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.logs.value.isEmpty) {
                  return _buildLoadingState();
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return _buildErrorState();
                }

                return _buildLogsDisplay();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Column(
        children: [
          // Source tabs
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _buildSourceTab(
                    LogSource.server,
                    'AirBar Server',
                    Icons.dns,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildSourceTab(
                    LogSource.postgres,
                    'PostgreSQL',
                    Icons.storage,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildSourceTab(
                    LogSource.redis,
                    'Redis',
                    Icons.memory,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // Max lines and refresh controls
          Row(
            children: [
              Text(
                'Lignes max:',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: 8.w),
              Obx(
                () => DropdownButton<int>(
                  value: controller.maxLines.value,
                  items: [100, 500, 1000, 5000].map((lines) {
                    return DropdownMenuItem(
                      value: lines,
                      child: Text(lines.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.changeMaxLines(value);
                    }
                  },
                ),
              ),
              const Spacer(),
              Obx(
                () => controller.isLoading.value
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: controller.loadLogs,
                        tooltip: 'Actualiser',
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSourceTab(LogSource source, String label, IconData icon) {
    final isSelected = controller.currentSource.value == source;

    return InkWell(
      onTap: () => controller.changeSource(source),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24.w,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
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
            'Chargement des logs...',
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
              onPressed: controller.loadLogs,
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

  Widget _buildLogsDisplay() {
    return Container(
      color: const Color(0xFF1E1E1E), // Dark terminal background
      padding: EdgeInsets.all(16.w),
      child: Obx(() {
        if (controller.logs.value.isEmpty) {
          return Center(
            child: Text(
              'Aucun log disponible',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[400],
                fontFamily: 'monospace',
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: SelectableText(
            controller.logs.value,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[300],
              fontFamily: 'monospace',
              height: 1.4,
            ),
          ),
        );
      }),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    Get.defaultDialog(
      title: 'Confirmer',
      titleStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
      middleText: 'Êtes-vous sûr de vouloir effacer les logs ?',
      middleTextStyle: TextStyle(fontSize: 14.sp),
      textCancel: 'Annuler',
      textConfirm: 'Effacer',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.stepError,
      onConfirm: () {
        Get.back();
        controller.clearLogs();
      },
    );
  }
}
