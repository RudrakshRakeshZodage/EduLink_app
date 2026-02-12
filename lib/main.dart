import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/tutor_list_screen.dart';
import 'screens/service_detail_screen.dart';
import 'screens/group_study_screen.dart';
import 'screens/admin/student_admin_panel.dart';
import 'screens/admin/tutor_admin_panel.dart';
import 'screens/teacher/teacher_dashboard.dart';
import 'screens/ai_tutor_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/student_management_screen.dart';
import 'widgets/bottom_navigation.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('FIREBASE INIT ERROR: $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const EduLinkApp(),
    ),
  );
}

class AppState extends ChangeNotifier {
  String _currentScreen = 'splash';
  bool _isLoggedIn = false;
  String _userType = 'student'; // 'student' or 'tutor'

  String get currentScreen => _currentScreen;
  bool get isLoggedIn => _isLoggedIn;
  String get userType => _userType;

  void setScreen(String screen) {
    _currentScreen = screen;
    notifyListeners();
  }

  void login(String type) {
    _isLoggedIn = true;
    _userType = type;
    _currentScreen = 'home';
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _currentScreen = 'login';
    notifyListeners();
  }
}

class EduLinkApp extends StatelessWidget {
  const EduLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduLink',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B5CF6)), // Purple-500
        scaffoldBackgroundColor: const Color(0xFFF9FAFB), // Gray-50
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const MainLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    // Simple routing based on state
    Widget getScreen() {
      switch (appState.currentScreen) {
        case 'splash':
          return const SplashScreen();
        case 'login':
          return const LoginScreen();
        case 'home':
          return const HomeScreen();
        case 'search':
          return const SearchScreen();
        case 'upload':
          return const UploadScreen();
        case 'chat':
          return const ChatScreen();
        case 'profile':
          return const ProfileScreen();
        case 'payment':
          return const PaymentScreen();
        case 'student-admin':
          return const StudentAdminPanel();
        case 'tutor-admin':
          return const TutorAdminPanel();
        case 'service-detail':
          return const ServiceDetailScreen();
        case 'tutor-list':
          return const TutorListScreen();
        case 'group-study':
          return const GroupStudyScreen();
        case 'teacher-dashboard':
          return const TeacherDashboardScreen();
        case 'ai-tutor':
          return const AiTutorScreen();
        case 'notifications':
          return const NotificationScreen();
        case 'student-management':
          return const StudentManagementScreen();
        default:
          return const HomeScreen();
      }
    }

    return Scaffold(
      body: getScreen(),
      bottomNavigationBar: (appState.isLoggedIn && 
          !['splash', 'login', 'student-admin', 'tutor-admin', 'chat', 'service-detail', 'group-study', 'upload', 'teacher-dashboard'].contains(appState.currentScreen))
          ? BottomNavigation(
              currentScreen: appState.currentScreen,
              onNavigate: (screen) => appState.setScreen(screen),
            )
          : null,
    );
  }
}
