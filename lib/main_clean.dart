import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/landing_page.dart';
import 'screens/enhanced_login_screen.dart';
import 'screens/forgot_password_page.dart';
import 'screens/home_screen.dart';
import 'services/user_service.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final userService = UserService();
  final notificationService = NotificationService();
  final authService = AuthService();

  await userService.initialize();
  await notificationService.initialize();

  runApp(FoodLoopApp(
    userService: userService,
    notificationService: notificationService,
    authService: authService,
  ));
}

class FoodLoopApp extends StatelessWidget {
  final UserService userService;
  final NotificationService notificationService;
  final AuthService authService;

  const FoodLoopApp({
    super.key,
    required this.userService,
    required this.notificationService,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserService>.value(value: userService),
        ChangeNotifierProvider<NotificationService>.value(
            value: notificationService),
        ChangeNotifierProvider<AuthService>.value(value: authService),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FoodLoop PH',
        theme: ThemeData(
          primarySwatch: Colors.amber,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        home: Consumer<AuthService>(
          builder: (context, authService, child) {
            if (authService.isAuthenticated) {
              return HomeScreen();
            } else {
              return LandingPage();
            }
          },
        ),
        routes: {
          '/login': (context) => EnhancedLoginScreen(),
          '/forgot-password': (context) => ForgotPasswordPage(),
          '/home': (context) => HomeScreen(),
        },
      ),
    );
  }
}
