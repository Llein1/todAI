import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'utils/constants.dart';
import 'providers/ai_provider.dart';
import 'providers/todo_provider.dart';
import 'providers/streak_provider.dart';
import 'services/database_helper.dart';
import 'services/notification_service.dart';
import 'screens/home_page.dart';
import 'screens/task_list_page.dart';
import 'screens/add_edit_task_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize database
  await DatabaseHelper().initDatabase();
  
  // Initialize notifications
  await NotificationService().initialize();
  await NotificationService().requestPermissions();
  
  runApp(const TodAIApp());
}

class TodAIApp extends StatelessWidget {
  const TodAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AIProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(create: (_) => StreakProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
      
      // Material 3 Light Theme
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryLight,
          ),
      
          // Card Theme
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
      
          // Input Decoration Theme
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            filled: true,
          ),
        ),
      
        // Dark Theme
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryDark,
            brightness: Brightness.dark,
          ),
      
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
      
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            filled: true,
          ),
        ),
        themeMode: ThemeMode.system,
        
        // Home and Routes
        home: const HomePage(),
        routes: {
          '/tasks': (context) => const TaskListPage(),
          '/add-task': (context) => const AddEditTaskPage(),
        },
      ),
    );
  }
}

/// Placeholder Home Page - Will be replaced in Phase 5
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('todAI'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.smart_toy_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'todAI',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI-Powered Task Manager',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // TODO: Navigate to main screen
              },
              icon: const Icon(Icons.rocket_launch),
              label: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
