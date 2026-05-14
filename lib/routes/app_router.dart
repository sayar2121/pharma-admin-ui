import 'package:go_router/go_router.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/update_profile_screen.dart';
import '../screens/available_medicine/available_medicine_screen.dart';
import '../screens/medicine_inventory/add_to_inventory_screen.dart';
import '../screens/medicine_inventory/medicine_inventory_screen.dart';
import '../screens/medicine_inventory/medicine_details_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/about_us/about_us_screen.dart';
import '../models/available_medicine.dart';
import '../models/medicine_inventory.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
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
      path: '/add-to-inventory',
      builder: (context, state) {
        final medicine = state.extra as AvailableMedicine;
        return AddToInventoryScreen(medicine: medicine);
      },
    ),
    GoRoute(
      path: '/medicine-inventory',
      builder: (context, state) => const MedicineInventoryScreen(),
    ),
    GoRoute(
      path: '/medicine-details',
      builder: (context, state) {
        final item = state.extra as MedicineInventory;
        return MedicineDetailsScreen(inventoryItem: item);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/about-us',
      builder: (context, state) => const AboutUsScreen(),
    ),
  ],
);
