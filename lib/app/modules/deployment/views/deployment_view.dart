import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/deployment_controller.dart';

class DeploymentView extends GetView<DeploymentController> {
  const DeploymentView({super.key});

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
                'Déploiement',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Déploiement et démarrage du serveur AirBar',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 32.h),

              // Progress indicator
              Obx(() => _buildProgressSection()),

              SizedBox(height: 24.h),

              // Deployment steps
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(32.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Étapes de déploiement',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Expanded(child: Obx(() => _buildStepsList())),
                      ],
                    ),
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
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.currentStep.value.isNotEmpty
                            ? controller.currentStep.value
                            : 'Préparation du déploiement...',
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
                          value: controller.deploymentProgress.value,
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
                // Status icon
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: controller.hasError.value
                        ? AppColors.stepError.withOpacity(0.1)
                        : controller.isComplete.value
                        ? AppColors.stepSuccess.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                  ),
                  child: Center(
                    child:
                        controller.isDeploying.value &&
                            !controller.hasError.value
                        ? SizedBox(
                            width: 30.w,
                            height: 30.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.w,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          )
                        : Icon(
                            controller.hasError.value
                                ? Icons.error
                                : controller.isComplete.value
                                ? Icons.check_circle
                                : Icons.rocket_launch,
                            size: 32.w,
                            color: controller.hasError.value
                                ? AppColors.stepError
                                : controller.isComplete.value
                                ? AppColors.stepSuccess
                                : AppColors.primary,
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

  Widget _buildStepsList() {
    if (controller.deploymentSteps.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: controller.deploymentSteps.length,
      itemBuilder: (context, index) {
        final step = controller.deploymentSteps[index];
        return _buildStepItem(step, index);
      },
    );
  }

  Widget _buildStepItem(DeploymentStep step, int index) {
    Color statusColor;
    IconData statusIcon;

    switch (step.status) {
      case StepStatus.pending:
        statusColor = AppColors.stepPending;
        statusIcon = Icons.radio_button_unchecked;
        break;
      case StepStatus.inProgress:
        statusColor = AppColors.stepInProgress;
        statusIcon = Icons.refresh;
        break;
      case StepStatus.success:
        statusColor = AppColors.stepSuccess;
        statusIcon = Icons.check_circle;
        break;
      case StepStatus.error:
        statusColor = AppColors.stepError;
        statusIcon = Icons.error;
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: step.status == StepStatus.inProgress
            ? AppColors.primary.withOpacity(0.05)
            : AppColors.background,
        borderRadius: BorderRadius.circular(8.w),
        border: Border.all(
          color: step.status == StepStatus.inProgress
              ? AppColors.primary.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          // Step number
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withOpacity(0.1),
              border: Border.all(color: statusColor, width: 2.w),
            ),
            child: Center(
              child: step.status == StepStatus.inProgress
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    )
                  : Icon(statusIcon, size: 20.w, color: statusColor),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  step.description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (step.errorMessage != null) ...[
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.stepError.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.w),
                    ),
                    child: Text(
                      step.errorMessage!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.stepError,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back/Skip button
        if (!controller.isDeploying.value)
          TextButton(
            onPressed: controller.isComplete.value
                ? controller.goBack
                : controller.skipDeployment,
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
                onPressed: controller.retryDeployment,
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
                    Text('Terminer', style: TextStyle(fontSize: 16.sp)),
                    SizedBox(width: 8.w),
                    Icon(Icons.check, size: 20.w),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
