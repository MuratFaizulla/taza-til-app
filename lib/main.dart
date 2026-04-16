import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'controllers/word_controller.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Hive.initFlutter();
  await Hive.openBox('settings');

  final controller = Get.put(WordController());
  final initialMode =
      controller.isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
  final onboardingDone =
      Hive.box('settings').get('onboardingDone', defaultValue: false) as bool;

  runApp(TazaTilApp(
    initialThemeMode: initialMode,
    showOnboarding: !onboardingDone,
  ));
}

class TazaTilApp extends StatelessWidget {
  final ThemeMode initialThemeMode;
  final bool showOnboarding;
  const TazaTilApp({
    super.key,
    required this.initialThemeMode,
    required this.showOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Таза Тіл',
      debugShowCheckedModeBanner: false,
      themeMode: initialThemeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: showOnboarding ? const OnboardingScreen() : const HomeScreen(),
      // Apply user's font scale preference globally
      builder: (context, child) {
        final ctrl = Get.find<WordController>();
        return Obx(() => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(ctrl.fontScale.value),
              ),
              child: child!,
            ));
      },
    );
  }

  ThemeData _buildLightTheme() {
    const primary = Color(0xFF2E7D32);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: Colors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const primary = Color(0xFF4CAF50);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: const Color(0xFF1E1E1E),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardTheme: CardThemeData(
        color: const Color(0xFF2D2D2D),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
    );
  }
}
