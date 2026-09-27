// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:masjid_sabilillah/presentation/screens/splash_screen.dart';
import 'package:masjid_sabilillah/presentation/screens/login_screen.dart';
import 'package:masjid_sabilillah/presentation/screens/signup_screen.dart';
import 'package:masjid_sabilillah/presentation/screens/home_screen.dart';
import 'package:masjid_sabilillah/presentation/screens/prayer_times_screen.dart';
import 'package:masjid_sabilillah/presentation/screens/settings_screen.dart';
import 'package:masjid_sabilillah/presentation/screens/donasi_screen.dart';
import 'package:masjid_sabilillah/lokasi/views/home_view.dart';
// Tambahkan import GetX controller utama bila perlu
import 'package:masjid_sabilillah/core/providers/theme_controller.dart';
import 'package:masjid_sabilillah/core/constants/app_colors.dart';
// Tambahkan import pengumuman:
import 'package:masjid_sabilillah/database/features/announcements/views/announcement_list_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ThemeController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<ThemeController>(
      builder: (themeController) {
        if (!themeController.isInitialized.value) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return GetMaterialApp(
          getPages: [
            GetPage(name: '/splash', page: () => const SplashScreen()),
            GetPage(name: '/login', page: () => const LoginScreen()),
            GetPage(name: '/signup', page: () => const SignupScreen()),
            GetPage(name: '/', page: () => const HomeScreen()),
            GetPage(name: '/jadwal', page: () => const PrayerTimesScreen()),
            GetPage(name: '/pengaturan', page: () => const SettingsScreen()),
            GetPage(name: '/lokasi', page: () => const HomeView()),
            GetPage(name: '/donasi', page: () => const DonasiScreen()),
            GetPage(
              name: '/pengumuman',
              page: () => const AnnouncementListView(),
            ),
          ],
          initialRoute: '/splash',
          title: 'Masjid Sabilillah',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.lightPrimary),
          ),
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(primary: AppColors.darkPrimary),
          ),
          themeMode: themeController.isDarkMode.value
              ? ThemeMode.dark
              : ThemeMode.light,
        );
      },
    );
  }
}
