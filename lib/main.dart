import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/api_helper.dart';
import 'core/services/supabase_service.dart';
import 'core/services/storage_service.dart';
import 'config/theme/app_theme.dart';
import 'config/theme/theme_cubit.dart';
import 'config/routes/app_routes.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/ppt_repository.dart';
import 'presentation/screens/auth/bloc/auth_bloc.dart';
import 'presentation/screens/auth/bloc/auth_event.dart';
import 'presentation/screens/auth/bloc/auth_state.dart';
import 'presentation/screens/home/bloc/ppt_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await _initializeServices();

  runApp(const MyApp());
}

/// Initialize all services
Future<void> _initializeServices() async {
  // Initialize Storage Service
  await StorageService().init();

  // Initialize Supabase
  await SupabaseService().init();

  // Initialize API Helper
  ApiHelper().init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => PptRepository()),
        RepositoryProvider(create: (_) => StorageService()),
      ],
      child: MultiBlocProvider(
        providers: [
          // Theme Cubit
          BlocProvider(
            create: (context) => ThemeCubit(
              storageService: context.read<StorageService>(),
            ),
          ),
          
          // Auth BLoC
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(const CheckLoginStatusEvent()),
          ),
          
          // PPT BLoC
          BlocProvider(
            create: (context) => PptBloc(
              pptRepository: context.read<PptRepository>(),
            ),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'MagicSlides',
              debugShowCheckedModeBanner: false,
              
              // Theme
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              
              // Routes
              onGenerateRoute: AppRoutes.generateRoute,
              
              // Initial Route
              home: const _InitialScreen(),
            );
          },
        ),
      ),
    );
  }
}

/// Initial Screen - Determines which screen to show based on auth state
class _InitialScreen extends StatelessWidget {
  const _InitialScreen();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          // Show splash/loading screen
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is AuthAuthenticated) {
          // User is authenticated, show home
          return const _Navigator(route: AppRoutes.home);
        } else {
          // User is not authenticated, show login
          return const _Navigator(route: AppRoutes.login);
        }
      },
    );
  }
}

/// Navigator wrapper to handle route navigation
class _Navigator extends StatelessWidget {
  final String route;

  const _Navigator({required this.route});

  @override
  Widget build(BuildContext context) {
    // Use addPostFrameCallback to navigate after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(route);
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
