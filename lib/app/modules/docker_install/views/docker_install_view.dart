import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/docker_install_controller.dart';

class DockerInstallView extends GetView<DockerInstallController> {
  const DockerInstallView({super.key});

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
                'Installation de Docker Desktop',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Docker Desktop est nécessaire pour exécuter les conteneurs du serveur',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 40.h),

              // Progress Card
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(32.w),
                    child: Obx(() => _buildProgressContent()),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Action Buttons
              Obx(() => _buildActionButtons()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressContent() {
    if (controller.isInstalled) {
      return _buildSuccessContent();
    } else if (controller.hasError) {
      return _buildErrorContent();
    } else if (controller.isInstalling) {
      return _buildInstallingContent();
    } else {
      return _buildReadyContent();
    }
  }

  Widget _buildReadyContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.download, size: 80.w, color: AppColors.primary),
        SizedBox(height: 24.h),
        Text(
          'Prêt à installer Docker Desktop',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'L\'installation va télécharger et installer Docker Desktop.\n'
          'Cette opération peut prendre plusieurs minutes.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildInstallingContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated progress indicator
        SizedBox(
          width: 100.w,
          height: 100.w,
          child: CircularProgressIndicator(
            value: controller.progress > 0 ? controller.progress : null,
            strokeWidth: 6.w,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        SizedBox(height: 32.h),

        Text(
          'Installation en cours...',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        SizedBox(height: 16.h),

        // Progress percentage
        if (controller.progress > 0)
          Text(
            '${(controller.progress * 100).toInt()}%',
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
          child: Column(
            children: [
              Row(
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
                      controller.message.isNotEmpty
                          ? controller.message
                          : 'Installation en cours...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.stepInProgress,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 24.h),

        Text(
          'Cette opération peut prendre plusieurs minutes.\n'
          'Merci de patienter...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
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
          'Docker Desktop installé avec succès !',
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 20.w,
                color: AppColors.stepSuccess,
              ),
              SizedBox(width: 12.w),
              Text(
                'Docker est prêt à être utilisé',
                style: TextStyle(fontSize: 14.sp, color: AppColors.stepSuccess),
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
          'Erreur d\'installation',
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
            color: AppColors.stepError.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.w),
            border: Border.all(color: AppColors.stepError.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(Icons.warning_amber, size: 24.w, color: AppColors.stepError),
              SizedBox(height: 8.h),
              Text(
                controller.errorMsg.isNotEmpty
                    ? controller.errorMsg
                    : 'Une erreur est survenue lors de l\'installation',
                style: TextStyle(fontSize: 14.sp, color: AppColors.stepError),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Vous pouvez réessayer l\'installation automatique ou\n'
          'installer Docker Desktop manuellement depuis docker.com',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Skip button (only if not installing)
        if (!controller.isInstalling)
          TextButton(
            onPressed: controller.skipInstallation,
            child: Text(
              'Ignorer',
              style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
            ),
          )
        else
          const SizedBox(),

        // Main action button
        Row(
          children: [
            // Retry button (only on error)
            if (controller.hasError) ...[
              OutlinedButton(
                onPressed: controller.retryInstallation,
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

            // Continue button (only if installed)
            if (controller.isInstalled)
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
