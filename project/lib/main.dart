// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'fire_base_auth/auth_wrapper.dart';
import 'provider/bottom_nav_provider.dart';
import 'provider/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavigationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        // Wait for theme initialization
        if (!themeProvider.isInitialized) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        // Base text theme
        final baseTextTheme = GoogleFonts.poppinsTextTheme();

        // 🌞 Light Theme
        final lightTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.grey[50],
          textTheme: baseTextTheme
              .apply(bodyColor: Colors.black87, displayColor: Colors.black87)
              .copyWith(
                displayLarge: baseTextTheme.displayLarge?.copyWith(
                  inherit: true,
                  color: Colors.black87,
                ),
                displayMedium: baseTextTheme.displayMedium?.copyWith(
                  inherit: true,
                  color: Colors.black87,
                ),
                displaySmall: baseTextTheme.displaySmall?.copyWith(
                  inherit: true,
                  color: Colors.black87,
                ),
                headlineLarge: baseTextTheme.headlineLarge?.copyWith(
                  inherit: true,
                  color: Colors.black87,
                ),
                headlineMedium: baseTextTheme.headlineMedium?.copyWith(
                  inherit: true,
                  color: Colors.black87,
                ),
                headlineSmall: baseTextTheme.headlineSmall?.copyWith(
                  inherit: true,
                  color: Colors.black87,
                ),
                titleLarge: baseTextTheme.titleLarge?.copyWith(
                  inherit: true,
                  color: Colors.black87,
                ),
                bodyLarge: baseTextTheme.bodyLarge?.copyWith(
                  inherit: true,
                  color: Colors.black87,
                ),
                bodyMedium: baseTextTheme.bodyMedium?.copyWith(
                  inherit: true,
                  color: Colors.black87,
                ),
                bodySmall: baseTextTheme.bodySmall?.copyWith(
                  inherit: true,
                  color: Colors.grey[700],
                ),
              ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0.5,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ).copyWith(inherit: true),
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            elevation: 8,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey,
            selectedIconTheme: const IconThemeData(size: 28),
            unselectedIconTheme: const IconThemeData(size: 24),
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
          ),
        );

        // 🌙 Dark Theme
        final darkTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          cardColor: const Color(0xFF1E1E1E),
          textTheme: baseTextTheme
              .apply(bodyColor: Colors.white, displayColor: Colors.white)
              .copyWith(
                displayLarge: baseTextTheme.displayLarge?.copyWith(
                  inherit: true,
                  color: Colors.white,
                ),
                displayMedium: baseTextTheme.displayMedium?.copyWith(
                  inherit: true,
                  color: Colors.white,
                ),
                displaySmall: baseTextTheme.displaySmall?.copyWith(
                  inherit: true,
                  color: Colors.white,
                ),
                headlineLarge: baseTextTheme.headlineLarge?.copyWith(
                  inherit: true,
                  color: Colors.white,
                ),
                headlineMedium: baseTextTheme.headlineMedium?.copyWith(
                  inherit: true,
                  color: Colors.white,
                ),
                headlineSmall: baseTextTheme.headlineSmall?.copyWith(
                  inherit: true,
                  color: Colors.white,
                ),
                titleLarge: baseTextTheme.titleLarge?.copyWith(
                  inherit: true,
                  color: Colors.white,
                ),
                bodyLarge: baseTextTheme.bodyLarge?.copyWith(
                  inherit: true,
                  color: Colors.white,
                ),
                bodyMedium: baseTextTheme.bodyMedium?.copyWith(
                  inherit: true,
                  color: Colors.white,
                ),
                bodySmall: baseTextTheme.bodySmall?.copyWith(
                  inherit: true,
                  color: Colors.grey[400],
                ),
              ),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF121212),
            foregroundColor: Colors.white,
            elevation: 0.5,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ).copyWith(inherit: true),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1F1F1F),
            elevation: 8,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            selectedIconTheme: IconThemeData(size: 28),
            unselectedIconTheme: IconThemeData(size: 24),
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
          ),
        );

        return MaterialApp(
          title: "Flutter Modern App",
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.currentTheme,
          theme: lightTheme,
          darkTheme: darkTheme,
          home: const AuthWrapper(),
          // ✅ Fix text scaling to prevent lerp issues
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
        );
      },
    );
  }
}
