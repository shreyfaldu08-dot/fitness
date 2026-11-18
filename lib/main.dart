import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/services/storage_service.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local persistent storage
  await StorageService.initialize();

  // Initialize Supabase client / offline handler
  await SupabaseService.initialize();

  runApp(
    const ProviderScope(
      child: FitoraApp(),
    ),
  );
}

class FitoraApp extends StatelessWidget {
  const FitoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Mobile-first responsive wrapper for desktop / widescreen web
            if (kIsWeb && constraints.maxWidth > 600) {
              const mobileWidth = 460.0;
              return Container(
                color: const Color(0xFF090D16), // Premium athletic midnight canvas
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Subtle background branding watermarks
                    Positioned(
                      top: 40,
                      child: Text(
                        'FITORA ATHLETIC PLATFORM',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.08),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    // Centered Smartphone Frame
                    Center(
                      child: Container(
                        width: mobileWidth,
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: const Color(0xFF1E293B), width: 3.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 36,
                              spreadRadius: 4,
                              offset: const Offset(0, 14),
                            ),
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                              blurRadius: 40,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              size: Size(mobileWidth, constraints.maxHeight - 40),
                            ),
                            child: child ?? const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}
