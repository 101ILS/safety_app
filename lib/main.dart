import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/firebase_employee_repository.dart'; 
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/start_shift_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/ai_chat_screen.dart';
import 'presentation/screens/ar_audit_screen.dart';
import 'presentation/screens/admin_dashboard_screen.dart';
import 'services/app_state.dart';
import 'presentation/screens/check_result_screen.dart';
import 'presentation/screens/check_history_screen.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SafetyAiApp());
}

class SafetyAiApp extends StatelessWidget {
  const SafetyAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => FirebaseEmployeeRepository()),
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Safety AI',
        theme: AppTheme.light,
        initialRoute: SplashScreen.routeName,
        routes: {
          LoginScreen.routeName: (_) => const LoginScreen(),
          StartShiftScreen.routeName: (_) => const StartShiftScreen(),
          DashboardScreen.routeName: (_) => const DashboardScreen(),
          ProfileScreen.routeName: (_) => const ProfileScreen(),
          AiChatScreen.routeName: (_) => const AiChatScreen(),
          ArAuditScreen.routeName: (_) => const ArAuditScreen(),
          AdminDashboardScreen.routeName: (_) => const AdminDashboardScreen(),
          CheckResultScreen.routeName: (_) => const CheckResultScreen(),
          CheckHistoryScreen.routeName: (_) => const CheckHistoryScreen(),
          SplashScreen.routeName: (_) => const SplashScreen(),
        },
      ),
    );
  }
}