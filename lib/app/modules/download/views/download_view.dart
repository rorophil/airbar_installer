import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/download_controller.dart';

class DownloadView extends GetView<DownloadController> {
  const DownloadView({super.key});

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
                'Téléchargement',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Téléchargement du code source du serveur AirBar',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 32.h),

              // Progress Card
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(32.w),
                    child: Column(
                      children: [
                        Expanded(child: Obx(() => _buildContent())),
                        SizedBox(height: 24.h),
                        Obx(() => _buildVerificationList()),
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

  Widget _buildContent() {
    if (controller.isComplete.value) {
      return _buildSuccessContent();
    } else if (controller.hasError.value) {
      return _buildErrorContent();
    } else if (controller.isDownloading.value) {
      return _buildDownloadingContent();
    } else {
      return _buildReadyContent();
    }
  }

  Widget _buildReadyContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_download, size: 80.w, color: AppColors.primary),
        SizedBox(height: 24.h),
        Text(
          'Prêt à télécharger',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Le repository AirBar Backend va être téléchargé\n'
          'dans le dossier d\'installation.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
        ),
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.w),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder, size: 20.w, color: AppColors.info),
              SizedBox(width: 12.w),
              Flexible(
                child: Text(
                  'Dossier: ${controller.installPath}',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.info),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadingContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated progress indicator
        SizedBox(
          width: 120.w,
          height: 120.w,
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  width: 120.w,
                  height: 120.w,
                  child: CircularProgressIndicator(
                    value: controller.downloadProgress.value > 0
                        ? controller.downloadProgress.value
                        : null,
                    strokeWidth: 8.w,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),
              Center(
                child: Icon(
                  Icons.download,
                  size: 48.w,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 32.h),

        Text(
          'Téléchargement en cours...',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        SizedBox(height: 16.h),

        // Progress percentage
        if (controller.downloadProgress.value > 0)
          Text(
            '${(controller.downloadProgress.value * 100).toInt()}%',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),

        SizedBox(height: 16.h),

        // Status message
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.stepInProgress.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.w),
            border: Border.all(
              color: AppColors.stepInProgress.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16.w,
                height: 16.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.stepInProgress,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Flexible(
                child: Text(
                  controller.downloadMessage.value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.stepInProgress,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle, size: 80.w, color: AppColors.stepSuccess),
        SizedBox(height: 24.h),
        Text(
          'Téléchargement terminé !',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.stepSuccess.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.w),
            border: Border.all(color: AppColors.stepSuccess.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 24.w,
                color: AppColors.stepSuccess,
              ),
              SizedBox(height: 8.h),
              Text(
                'Tous les fichiers ont été téléchargés et vérifiés avec succès',
                style: TextStyle(fontSize: 14.sp, color: AppColors.stepSuccess),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error, size: 80.w, color: AppColors.stepError),
        SizedBox(height: 24.h),
        Text(
          'Erreur de téléchargement',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Vous pouvez réessayer le téléchargement ou\n'
          'télécharger manuellement depuis GitHub.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildVerificationList() {
    if (controller.verificationSteps.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vérification des fichiers',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          ...controller.verificationSteps.map(
            (step) => _buildVerificationItem(step),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationItem(VerificationStep step) {
    Color statusColor;
    IconData statusIcon;

    switch (step.status) {
      case VerificationStatus.pending:
        statusColor = AppColors.stepPending;
        statusIcon = Icons.radio_button_unchecked;
        break;
      case VerificationStatus.checking:
        statusColor = AppColors.stepInProgress;
        statusIcon = Icons.refresh;
        break;
      case VerificationStatus.success:
        statusColor = AppColors.stepSuccess;
        statusIcon = Icons.check_circle;
        break;
      case VerificationStatus.error:
        statusColor = AppColors.stepError;
        statusIcon = Icons.error;
        break;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(statusIcon, size: 20.w, color: statusColor),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
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

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back/Skip button
        if (!controller.isDownloading.value)
          TextButton(
            onPressed: controller.isComplete.value
                ? controller.goBack
                : controller.skipDownload,
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
                onPressed: controller.retryDownload,
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
          ],
        ),
      ],
    );
  }
}
