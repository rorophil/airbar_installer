import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/system_check_controller.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/values/app_strings.dart';
import '../../../services/system_check_service.dart';

class SystemCheckView extends GetView<SystemCheckController> {
  const SystemCheckView({super.key});

  @override
  Widget build(BuildContext context) {
    final systemCheckService = Get.find<SystemCheckService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.stepSystemCheck),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              AppStrings.checkingSystem,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32.h),

            // Checks List
            Expanded(
              child: Obx(
                () => ListView.separated(
                  itemCount: systemCheckService.checks.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final check = systemCheckService.checks[index];
                    return _CheckCard(check: check);
                  },
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Summary
            Obx(() {
              if (controller.isRunningChecks.value) {
                return const SizedBox.shrink();
              }

              if (systemCheckService.hasCriticalErrors.value) {
                return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: AppColors.error, size: 24.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Des erreurs critiques doivent être résolues avant de continuer',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (systemCheckService.hasErrors.value) {
                return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: AppColors.warning,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Des avertissements ont été détectés. L\'installation peut continuer.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.success),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Toutes les vérifications sont passées avec succès !',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: 24.h),

            // Action Buttons
            Obx(
              () => Row(
                children: [
                  // Retry Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.isRunningChecks.value
                          ? null
                          : controller.retryChecks,
                      icon: Icon(Icons.refresh, size: 20.sp),
                      label: Text(AppStrings.recheckSystem),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),

                  SizedBox(width: 16.w),

                  // Continue Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed:
                          controller.isRunningChecks.value ||
                              !controller.canProceed.value
                          ? null
                          : controller.proceedToNextStep,
                      icon: Icon(Icons.arrow_forward, size: 24.sp),
                      label: Text(AppStrings.next),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textWhite,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        disabledBackgroundColor: AppColors.textHint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckCard extends StatelessWidget {
  final SystemCheck check;

  const _CheckCard({required this.check});

  Color _getStatusColor(CheckStatus status) {
    switch (status) {
      case CheckStatus.pending:
        return AppColors.stepPending;
      case CheckStatus.checking:
        return AppColors.stepInProgress;
      case CheckStatus.success:
        return AppColors.stepSuccess;
      case CheckStatus.warning:
        return AppColors.stepWarning;
      case CheckStatus.error:
        return AppColors.stepError;
    }
  }

  IconData _getStatusIcon(CheckStatus status) {
    switch (status) {
      case CheckStatus.pending:
        return Icons.pending;
      case CheckStatus.checking:
        return Icons.hourglass_empty;
      case CheckStatus.success:
        return Icons.check_circle;
      case CheckStatus.warning:
        return Icons.warning;
      case CheckStatus.error:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = check.status.value;
      final statusColor = _getStatusColor(status);
      final statusIcon = _getStatusIcon(status);

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(
            color: status == CheckStatus.checking
                ? AppColors.primary
                : statusColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Status Icon
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: status == CheckStatus.checking
                    ? Padding(
                        padding: EdgeInsets.all(12.w),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            statusColor,
                          ),
                        ),
                      )
                    : Icon(statusIcon, color: statusColor, size: 28.sp),
              ),

              SizedBox(width: 16.w),

              // Check Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            check.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (check.isCritical)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'CRITIQUE',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      check.description,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (check.message.value.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Text(
                        check.message.value,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
