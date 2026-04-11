import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app/routes/app_pages.dart';
import 'app/core/theme/app_theme.dart';
import 'app/services/storage_service.dart';
import 'app/services/system_check_service.dart';
import 'app/services/docker_service.dart';
import 'app/services/git_service.dart';
import 'app/services/configuration_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await initServices();

  runApp(const AirBarInstallerApp());
}

Future<void> initServices() async {
  // Storage service (must be first)
  await Get.putAsync(() => StorageService().init());

  // System check service
  Get.put(SystemCheckService());

  // Docker service
  Get.put(DockerService());

  // Git service
  Get.put(GitService());

  // Configuration service
  Get.put(ConfigurationService());
}

class AirBarInstallerApp extends StatelessWidget {
  const AirBarInstallerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1280, 720), // Desktop design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'AirBar Server Installer',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
