import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/build_controller.dart';

class BuildView extends GetView<BuildController> {
  const BuildView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(40.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Construction',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Construction de l\'image Docker du serveur AirBar',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 32.h),

              // Progress indicator
              Obx(() => _buildProgressSection()),

              SizedBox(height: 24.h),

              // Logs section
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Row(
                          children: [
                            Icon(
                              Icons.terminal,
                              size: 20.w,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Logs de construction',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1.h),
                      Expanded(
                        child: Container(
                          color: const Color(0xFF1E1E1E),
                          padding: EdgeInsets.all(16.w),
                          child: Obx(() => _buildLogsContent()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Error message
              Obx(() {
                if (!controller.hasError.value) {
                  return const SizedBox();
                }
                return Container(
                  padding: EdgeInsets.all(12.w),
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.stepError.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.w),
                    border: Border.all(color: AppColors.stepError),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.stepError,
                        size: 20.w,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.stepError,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Action Buttons
              Obx(() => _buildActionButtons()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            // Progress bar
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.currentStep.value,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.w),
                        child: LinearProgressIndicator(
                          value: controller.buildProgress.value,
                          minHeight: 8.h,
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            controller.hasError.value
                                ? AppColors.stepError
                                : controller.isComplete.value
                                ? AppColors.stepSuccess
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 24.w),
                // Progress percentage
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: controller.hasError.value
                          ? AppColors.stepError
                          : controller.isComplete.value
                          ? AppColors.stepSuccess
                          : AppColors.primary,
                      width: 3.w,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${(controller.buildProgress.value * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: controller.hasError.value
                            ? AppColors.stepError
                            : controller.isComplete.value
                            ? AppColors.stepSuccess
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsContent() {
    if (controller.buildLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notes, size: 48.w, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'Les logs de construction apparaîtront ici...',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: controller.buildLogs.length,
      itemBuilder: (context, index) {
        final log = controller.buildLogs[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Text(
            log,
            style: TextStyle(
              fontSize: 13.sp,
              fontFamily: 'monospace',
              color: _getLogColor(log),
            ),
          ),
        );
      },
    );
  }

  Color _getLogColor(String log) {
    if (log.startsWith('✅')) return const Color(0xFF4CAF50);
    if (log.startsWith('❌')) return const Color(0xFFF44336);
    if (log.startsWith('🐳') || log.startsWith('📝') || log.startsWith('🔍')) {
      return const Color(0xFF2196F3);
    }
    if (log.startsWith('🎉')) return const Color(0xFFFF9800);
    if (log.contains('Step')) return const Color(0xFFFFB74D);
    if (log.contains('Successfully')) return const Color(0xFF4CAF50);
    return const Color(0xFFE0E0E0);
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back/Skip button
        if (!controller.isBuilding.value)
          TextButton(
            onPressed: controller.isComplete.value
                ? controller.goBack
                : controller.skipBuild,
            child: Row(
              children: [
                if (!controller.isComplete.value)
                  Icon(Icons.skip_next, size: 20.w),
                if (controller.isComplete.value)
                  Icon(Icons.arrow_back, size: 20.w),
                SizedBox(width: 8.w),
                Text(
                  controller.isComplete.value ? 'Retour' : 'Ignorer',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ],
            ),
          )
        else
          const SizedBox(),

        // Main action buttons
        Row(
          children: [
            // Retry button (only on error)
            if (controller.hasError.value) ...[
              OutlinedButton(
                onPressed: controller.retryBuild,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 16.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                ),
                child: Text('Réessayer', style: TextStyle(fontSize: 16.sp)),
              ),
              SizedBox(width: 16.w),
            ],

            // Continue button (only if complete)
            if (controller.isComplete.value)
              ElevatedButton(
                onPressed: controller.goToNextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 16.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                ),
                child: Row(
                  children: [
                    Text('Continuer', style: TextStyle(fontSize: 16.sp)),
                    SizedBox(width: 8.w),
                    Icon(Icons.arrow_forward, size: 20.w),
                  ],
                ),
              ),

            // Building indicator
            if (controller.isBuilding.value && !controller.hasError.value)
              Row(
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Construction en cours...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
