import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_initialization_provider.dart';

/// Firebase Initialization Splash Screen
/// 
/// This widget displays during Firebase initialization and shows:
/// - Loading state while initializing
/// - Success state when ready
/// - Error state with helpful debugging information
class FirebaseInitializationSplashScreen extends ConsumerWidget {
  final Widget? child;

  const FirebaseInitializationSplashScreen({
    this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initState = ref.watch(firebaseInitializationProvider);

    // Show loading screen during initialization
    if (initState.isInitializing) {
      return _buildLoadingScreen();
    }

    // If initialization failed, show the error screen instead of continuing.
    if (initState.hasError) {
      return _buildErrorScreen(ref, initState.errorMessage ?? 'Unknown error');
    }

    // Show child widget if initialization succeeded
    if (initState.isInitialized && child != null) {
      return child!;
    }

    // Fallback loading screen
    return _buildLoadingScreen();
  }

  Widget _buildLoadingScreen() {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Firebase logo animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (value * 0.2),
                    child: Opacity(
                      opacity: 0.7 + (value * 0.3),
                      child: const Icon(
                        Icons.local_fire_department,
                        size: 64,
                        color: Color(0xFFFFA500),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Problem Solvers Hub',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Initializing Firebase...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFA500)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(WidgetRef ref, String errorMessage) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Initialization Error'),
          backgroundColor: Colors.red,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Firebase Initialization Failed',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Error Details:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.blue.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Troubleshooting:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTroubleshootingPoint(
                          '1. iOS: Ensure GoogleService-Info.plist is added to Xcode project',
                        ),
                        _buildTroubleshootingPoint(
                          '2. Android: Verify google-services.json in android/app/',
                        ),
                        _buildTroubleshootingPoint(
                          '3. Linux desktop may not be supported by current Firebase plugins',
                        ),
                        _buildTroubleshootingPoint(
                          '4. Clean build: Run flutter clean',
                        ),
                        _buildTroubleshootingPoint(
                          '4. Rebuild: Run flutter pub get',
                        ),
                        _buildTroubleshootingPoint(
                          '5. Check Firebase Console for project configuration',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(firebaseInitializationProvider.notifier).initialize();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTroubleshootingPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black87,
        ),
      ),
    );
  }
}
