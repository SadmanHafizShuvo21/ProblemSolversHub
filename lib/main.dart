import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:problem_solvers_hub/core/service_locator.dart';
import 'package:problem_solvers_hub/ui/app.dart';
import 'core/firebase/firebase_initialization_provider.dart';
import 'core/firebase/firebase_initialization_splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadEnvironmentVariables();
  setupServiceLocator();
    

  runApp(
    ProviderScope(
      child: _AppInitializationWrapper(),
    ),
  );
}

Future<void> _loadEnvironmentVariables() async {
  try {
    await dotenv.load(fileName: 'lib/.env');
    debugPrint('✅ Environment variables loaded');
  } catch (e) {
    debugPrint('⚠️  Warning: .env file not found, using default values');
  }
}

class _AppInitializationWrapper extends ConsumerWidget {
  const _AppInitializationWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initState = ref.watch(firebaseInitializationProvider);

    if (!initState.isInitializing && !initState.isInitialized && !initState.hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeFirebase(ref);
      });
    }

    return FirebaseInitializationSplashScreen(
      child: const ProblemSolversHubApp(),
    );
  }

  void _initializeFirebase(WidgetRef ref) {
    final state = ref.read(firebaseInitializationProvider);
    if (state.isInitializing || state.isInitialized) return;
    ref.read(firebaseInitializationProvider.notifier).initialize();
  }
}
