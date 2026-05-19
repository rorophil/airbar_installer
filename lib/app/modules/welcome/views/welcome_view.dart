import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/welcome_controller.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/values/app_strings.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.stepWelcome), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Title
            Text(
              AppStrings.welcomeTitle,
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24.h),

            // Description
            Text(
              AppStrings.welcomeDescription,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 48.h),

            // Mode Selection Cards
            Expanded(
              child: Row(
                children: [
                  // Simple Mode Card
                  Expanded(
                    child: Obx(
                      () => _ModeCard(
                        title: AppStrings.installSimple,
                        description:
                            'Installation rapide avec valeurs par défaut sécurisées. Recommandé pour la plupart des utilisateurs.',
                        icon: Icons.auto_awesome,
                        isSelected:
                            controller.selectedMode.value == InstallMode.simple,
                        isRecommended: true,
                        onTap: () => controller.selectMode(InstallMode.simple),
                      ),
                    ),
                  ),

                  SizedBox(width: 24.w),

                  // Advanced Mode Card
                  Expanded(
                    child: Obx(
                      () => _ModeCard(
                        title: AppStrings.installAdvanced,
                        description:
                            'Contrôle total sur tous les paramètres d\'installation. Pour utilisateurs expérimentés.',
                        icon: Icons.settings,
                        isSelected:
                            controller.selectedMode.value ==
                            InstallMode.advanced,
                        isRecommended: false,
                        onTap: () =>
                            controller.selectMode(InstallMode.advanced),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Info Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time,
                  size: 20.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 8.w),
                Text(
                  AppStrings.estimatedTime,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Action Buttons
            Row(
              children: [
                // Documentation Button
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: controller.openDocumentation,
                    icon: Icon(Icons.menu_book, size: 20.sp),
                    label: const Text('Documentation'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),

                SizedBox(width: 16.w),

                // Start Button
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: controller.startInstallation,
                    icon: Icon(Icons.play_arrow, size: 24.sp),
                    label: const Text('Démarrer l\'installation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textWhite,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
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
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final bool isRecommended;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.isRecommended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textHint,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Recommended Badge
            if (isRecommended)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'RECOMMANDÉ',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
              ),

            if (isRecommended) SizedBox(height: 8.h),

            // Icon
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40.sp,
                color: isSelected ? AppColors.textWhite : AppColors.primary,
              ),
            ),

            SizedBox(height: 12.h),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12.h),

            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12.h),

            // Selection Indicator
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.success : AppColors.textHint,
              size: 32.sp,
            ),
          ],
        ),
      ),
    );
  }
}
