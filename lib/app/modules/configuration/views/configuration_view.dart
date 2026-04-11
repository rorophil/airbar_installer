import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/configuration_controller.dart';

class ConfigurationView extends GetView<ConfigurationController> {
  const ConfigurationView({super.key});

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
                'Configuration',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Configurez les paramètres d\'installation du serveur AirBar',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 32.h),

              // Form
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(32.w),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Installation Path
                          _buildSectionTitle('Chemin d\'installation'),
                          _buildTextField(
                            controller: controller.installPathController,
                            label: 'Chemin d\'installation',
                            hint: 'C:\\AirBar',
                            icon: Icons.folder,
                            validator: controller.validatePath,
                            readOnly: !controller.isAdvancedMode.value,
                          ),
                          SizedBox(height: 24.h),

                          // API Configuration
                          _buildSectionTitle('Configuration API'),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildTextField(
                                  controller: controller.apiHostController,
                                  label: 'Hôte API',
                                  hint: 'localhost',
                                  icon: Icons.dns,
                                  validator: controller.validateHost,
                                  readOnly: !controller.isAdvancedMode.value,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.apiPortController,
                                  label: 'Port API',
                                  hint: '8080',
                                  icon: Icons.settings_ethernet,
                                  keyboardType: TextInputType.number,
                                  validator: controller.validatePort,
                                  readOnly: !controller.isAdvancedMode.value,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // Other Ports
                          Obx(() {
                            if (!controller.isAdvancedMode.value) {
                              return const SizedBox();
                            }
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller:
                                            controller.insightsPortController,
                                        label: 'Port Insights',
                                        hint: '8082',
                                        icon: Icons.analytics,
                                        keyboardType: TextInputType.number,
                                        validator: controller.validatePort,
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: _buildTextField(
                                        controller:
                                            controller.webPortController,
                                        label: 'Port Web',
                                        hint: '8081',
                                        icon: Icons.web,
                                        keyboardType: TextInputType.number,
                                        validator: controller.validatePort,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24.h),
                              ],
                            );
                          }),

                          // Database Passwords
                          _buildSectionTitle(
                            'Mots de passe (générés automatiquement)',
                          ),
                          SizedBox(height: 8.h),
                          Obx(
                            () => _buildPasswordDisplay(
                              'PostgreSQL',
                              controller.postgresPassword,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Obx(
                            () => _buildPasswordDisplay(
                              'Redis',
                              controller.redisPassword,
                            ),
                          ),

                          SizedBox(height: 16.h),
                          Container(
                            padding: EdgeInsets.all(12.w),
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
                                    'Ces mots de passe seront utilisés pour sécuriser les bases de données.\n'
                                    'Ils seront sauvegardés dans les fichiers de configuration.',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Error message
              Obx(() {
                if (controller.errorMessage.value.isEmpty) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: controller.goBack,
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back, size: 20.w),
                        SizedBox(width: 8.w),
                        Text('Retour', style: TextStyle(fontSize: 16.sp)),
                      ],
                    ),
                  ),
                  Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.saveAndContinue,
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
                      child: controller.isLoading.value
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.w,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              children: [
                                Text(
                                  'Continuer',
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                                SizedBox(width: 8.w),
                                Icon(Icons.arrow_forward, size: 20.w),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 14.sp,
        color: readOnly ? AppColors.textSecondary : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20.w),
        filled: readOnly,
        fillColor: readOnly ? AppColors.background : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.w)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  Widget _buildPasswordDisplay(String label, String password) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.w),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.key, size: 20.w, color: AppColors.primary),
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
                  password,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'monospace',
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.copy, size: 20.w, color: AppColors.primary),
            onPressed: () => controller.copyToClipboard(password, label),
            tooltip: 'Copier',
          ),
        ],
      ),
    );
  }
}
