import 'package:flutter/material.dart';
import '../presentation/screens/welcome_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/signup_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/search_screen.dart';
import '../presentation/screens/profile_screen.dart';
import '../presentation/screens/settings_screen.dart';
import '../presentation/screens/forgot_password_screen.dart';
import '../presentation/screens/verification_screen.dart';
import '../presentation/screens/new_password_screen.dart';
import '../presentation/screens/notifications_screen.dart';
import '../presentation/screens/chat_screen.dart';
import '../presentation/screens/messages_screen.dart';
import '../presentation/screens/create_post_screen.dart';
import '../presentation/screens/ai_matching_results_screen.dart';
import '../presentation/screens/post_detail_screen.dart';
import '../presentation/screens/preview_post_screen.dart';
import '../presentation/screens/filter_screen.dart';
import '../presentation/screens/report_problem_screen.dart';
import '../presentation/screens/edit_profile_screen.dart';
import '../presentation/screens/change_password_screen.dart';

/// App Routes Configuration
class AppRoutes {
  static const String welcome = '/';
  static const String home = '/home';
  static const String search = '/search';
  static const String createPost = '/create-post';
  static const String postDetail = '/post-detail';
  static const String previewPost = '/preview-post';
  static const String profile = '/profile';
  static const String settingsRoute = '/settings';
  static const String chat = '/chat';
  static const String messages = '/messages';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String verification = '/verification';
  static const String newPassword = '/new-password';
  static const String notifications = '/notifications';
  static const String aiMatchingResults = '/ai-matching-results';
  static const String filter = '/filter';
  static const String reportProblem = '/report-problem';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());

      case createPost:
        return MaterialPageRoute(builder: (_) => const CreatePostScreen());

      case postDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('No post data provided')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => PostDetailScreen(postData: args),
        );

      case previewPost:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('No post data provided')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => PreviewPostScreen(postData: args),
        );

      case aiMatchingResults:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AIMatchingResultsScreen(postData: args),
        );

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());

      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case messages:
        return MaterialPageRoute(builder: (_) => const MessagesScreen());

      case chat:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            userName: args?['userName'],
            userId: args?['userId'],
            isOnline: args?['isOnline'],
          ),
        );

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case verification:
        return MaterialPageRoute(builder: (_) => const VerificationScreen());

      case newPassword:
        return MaterialPageRoute(builder: (_) => const NewPasswordScreen());

      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case filter:
        return MaterialPageRoute(builder: (_) => const FilterScreen());

      case reportProblem:
        return MaterialPageRoute(builder: (_) => const ReportProblemScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }
}
