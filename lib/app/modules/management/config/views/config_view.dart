import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/values/app_colors.dart';
import '../controllers/config_controller.dart';

class ConfigView extends GetView<ConfigController> {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Configuration'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return _buildLoadingState();
                    }

                    return _buildConfigForm();
                  }),
                ),
              ),
              SizedBox(height: 24.h),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(48.w),
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildConfigForm() {
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
                  Icons.settings_outlined,
                  size: 24.w,
                  color: AppColors.primary,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Paramètres du serveur',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // API Host
            _buildTextField(
              label: 'Hôte API',
              controller: controller.apiHostController,
              hint: 'localhost ou adresse IP',
              icon: Icons.computer,
              validator: (value) {
                if (value == null || !controller.validateHost(value)) {
                  return 'Hôte invalide (localhost ou IP valide)';
                }
                return null;
              },
            ),

            SizedBox(height: 20.h),

            // API Port
            _buildTextField(
              label: 'Port API',
              controller: controller.apiPortController,
              hint: '8080',
              icon: Icons.settings_ethernet,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || !controller.validatePort(value)) {
                  return 'Port invalide (1-65535)';
                }
                return null;
              },
            ),

            SizedBox(height: 20.h),

            // Web Port
            _buildTextField(
              label: 'Port Web',
              controller: controller.webPortController,
              hint: '8081',
              icon: Icons.web,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || !controller.validatePort(value)) {
                  return 'Port invalide (1-65535)';
                }
                return null;
              },
            ),

            SizedBox(height: 20.h),

            // Insights Port
            _buildTextField(
              label: 'Port Insights',
              controller: controller.insightsPortController,
              hint: '8082',
              icon: Icons.analytics,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || !controller.validatePort(value)) {
                  return 'Port invalide (1-65535)';
                }
                return null;
              },
            ),

            SizedBox(height: 24.h),

            // Warning message
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.stepWarning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.w),
                border: Border.all(
                  color: AppColors.stepWarning.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20.w,
                    color: AppColors.stepWarning,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Les modifications nécessitent un redémarrage des services pour être appliquées.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textPrimary,
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20.w),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.w),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.w),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.w),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Obx(() {
      final hasChanges = controller.hasChanges.value;
      final isSaving = controller.isSaving.value;

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: hasChanges ? controller.resetToDefaults : null,
                  icon: Icon(Icons.restore, size: 20.w),
                  label: const Text('Réinitialiser'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: hasChanges && !isSaving
                      ? controller.saveConfiguration
                      : null,
                  icon: isSaving
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.save, size: 20.w),
                  label: Text(isSaving ? 'Enregistrement...' : 'Sauvegarder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.restartServices,
              icon: Icon(Icons.restart_alt, size: 20.w),
              label: const Text('Redémarrer les services'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.stepWarning,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.w),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
