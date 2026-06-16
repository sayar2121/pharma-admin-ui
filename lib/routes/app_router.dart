import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/order/order_management_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/update_profile_screen.dart';
import '../screens/available_medicine/available_medicine_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/about_us/about_us_screen.dart';
import '../screens/privacy_policy/privacy_policy_screen.dart';
import '../screens/terms_conditions/terms_conditions_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/earnings/earnings_screen.dart';
import '../cards/order/prescription_preview_card.dart';
import '../screens/notifications/notification_screen.dart';
import '../screens/settings/feedback_screen.dart';
import '../screens/settings/report_problem_screen.dart';

CustomTransitionPage buildPageWithSlideTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOutCubic;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/order-management',
      builder: (context, state) => const OrderManagementScreen(),
    ),
    GoRoute(
      path: '/update-profile',
      builder: (context, state) => const UpdateProfileScreen(),
    ),
    GoRoute(
      path: '/available-medicines',
      builder: (context, state) => const AvailableMedicineScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/about-us',
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context,
        state: state,
        child: const AboutUsScreen(),
      ),
    ),
    GoRoute(
      path: '/terms-conditions',
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context,
        state: state,
        child: const TermsConditionsScreen(),
      ),
    ),
    GoRoute(
      path: '/privacy-policy',
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context,
        state: state,
        child: const PrivacyPolicyScreen(),
      ),
    ),
    GoRoute(
      path: '/earnings',
      builder: (context, state) => const EarningsScreen(),
    ),
    GoRoute(
      path: '/map',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return MapScreen(
          initialLatitude: extra?['latitude'] as double?,
          initialLongitude: extra?['longitude'] as double?,
        );
      },
    ),
    GoRoute(
      path: '/prescription-preview',
      builder: (context, state) {
        final imageUrl = state.extra as String;
        return PrescriptionPreviewCard(imageUrl: imageUrl);
      },
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      path: '/feedback',
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context,
        state: state,
        child: const FeedbackScreen(),
      ),
    ),
    GoRoute(
      path: '/report-problem',
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context,
        state: state,
        child: const ReportProblemScreen(),
      ),
    ),
  ],
);
