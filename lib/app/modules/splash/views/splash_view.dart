import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/splash_controller.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/values/app_strings.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon/Logo
            Container(
              width: 200.w,
              height: 200.h,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.cloud_download,
                size: 120.sp,
                color: AppColors.primary,
              ),
            ),

            SizedBox(height: 40.h),

            // App Name
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 36.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),

            SizedBox(height: 12.h),

            // Tagline
            Text(
              AppStrings.appTagLine,
              style: TextStyle(
                fontSize: 18.sp,
                color: AppColors.textWhite.withOpacity(0.9),
              ),
            ),

            SizedBox(height: 60.h),

            // Loading indicator
            SizedBox(
              width: 40.w,
              height: 40.h,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.textWhite),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
