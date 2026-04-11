import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/success_controller.dart';

class SuccessView extends GetView<SuccessController> {
  const SuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(40.w),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 40.h),

                      // Success icon
                      Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.stepSuccess.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          size: 80.w,
                          color: AppColors.stepSuccess,
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Title
                      Text(
                        'Installation réussie !',
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      SizedBox(height: 16.h),

                      Text(
                        'Le serveur AirBar a été installé et déployé avec succès',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      SizedBox(height: 48.h),

                      // Installation summary
                      _buildSummaryCard(),

                      SizedBox(height: 24.h),

                      // Access URLs
                      _buildUrlsCard(),

                      SizedBox(height: 24.h),

                      // Next steps
                      _buildNextStepsCard(),

                      SizedBox(height: 24.h),

                      // Default credentials
                      _buildCredentialsCard(),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Finish button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.finish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Terminer',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(Icons.check, size: 24.w),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
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
                Icon(Icons.info_outline, size: 24.w, color: AppColors.primary),
                SizedBox(width: 12.w),
                Text(
                  'Résumé de l\'installation',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            _buildInfoRow('Emplacement', controller.installPath),
            _buildInfoRow('Hôte', controller.apiHost),
            _buildInfoRow('Port API', controller.apiPort.toString()),
            _buildInfoRow('Port Web', controller.webPort.toString()),
            _buildInfoRow('Port Insights', controller.insightsPort.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlsCard() {
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
                Icon(Icons.link, size: 24.w, color: AppColors.primary),
                SizedBox(width: 12.w),
                Text(
                  'URLs d\'accès',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            _buildUrlRow('API Server', controller.apiUrl, Icons.api),
            SizedBox(height: 12.h),
            _buildUrlRow('Web Interface', controller.webUrl, Icons.web),
            SizedBox(height: 12.h),
            _buildUrlRow('Insights', controller.insightsUrl, Icons.analytics),
          ],
        ),
      ),
    );
  }

  Widget _buildNextStepsCard() {
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
                  Icons.lightbulb_outline,
                  size: 24.w,
                  color: AppColors.primary,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Prochaines étapes',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildStepItem(
              '1',
              'Ouvrir l\'application AirBar Flutter',
              'Lancez l\'application mobile ou desktop',
            ),
            _buildStepItem(
              '2',
              'Configurer le serveur',
              'Entrez l\'adresse IP et le port (${controller.apiHost}:${controller.apiPort})',
            ),
            _buildStepItem(
              '3',
              'Se connecter',
              'Utilisez le code PIN par défaut pour vous connecter',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialsCard() {
    return Card(
      elevation: 2,
      color: AppColors.stepWarning.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.w),
        side: BorderSide(color: AppColors.stepWarning.withOpacity(0.3)),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  size: 24.w,
                  color: AppColors.stepWarning,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Compte administrateur par défaut',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Code PIN administrateur :',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        '123456',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      IconButton(
                        icon: Icon(
                          Icons.copy,
                          size: 20.w,
                          color: AppColors.primary,
                        ),
                        onPressed: () =>
                            controller.copyToClipboard('123456', 'Code PIN'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              '⚠️ Important : Changez ce code PIN dès votre première connexion !',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.stepWarning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
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

  Widget _buildUrlRow(String label, String url, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20.w, color: AppColors.primary),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  url,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.copy, size: 18.w, color: AppColors.primary),
                onPressed: () => controller.copyToClipboard(url, label),
                tooltip: 'Copier',
              ),
              IconButton(
                icon: Icon(
                  Icons.open_in_new,
                  size: 18.w,
                  color: AppColors.primary,
                ),
                onPressed: () => controller.openInBrowser(url),
                tooltip: 'Ouvrir',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String number, String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
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
}
