import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/property_detail_screen.dart';
import '../screens/add_property_screen.dart';
import '../screens/my_properties_screen.dart';
import '../screens/worker_services_screen.dart';
import '../screens/worker_dashboard_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/property_list_screen.dart';
import '../screens/service_detail_screen.dart';
import '../screens/my_requests_screen.dart';
import '../screens/review_screen.dart';
import '../models/property.dart';


final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(Constants.tokenKey);
    final isAuth = token != null && token.isNotEmpty;

    final publicRoutes = ['/login', '/register', '/splash'];
    final isPublic = publicRoutes.contains(state.matchedLocation);

    if (!isAuth && !isPublic) return '/login';
    if (isAuth && state.matchedLocation == '/login') return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/property/:id',
      builder: (_, state) {
        final property = state.extra as Property;
        return PropertyDetailScreen(property: property);
      },
    ),
    GoRoute(
      path: '/properties/add',
      builder: (_, state) => AddPropertyScreen(
        initialProperty: state.extra as Property?,
      ),
    ),
    GoRoute(path: '/properties/list', builder: (_, __) => const PropertyListScreen()),
    GoRoute(path: '/my-properties', builder: (_, __) => const MyPropertiesScreen()),
    GoRoute(path: '/services', builder: (_, __) => const WorkerServicesScreen()),
    GoRoute(
      path: '/services/:id',
      builder: (_, state) {
        final serviceId = int.parse(state.pathParameters['id']!);
        return ServiceDetailScreen(serviceId: serviceId);
      },
    ),
    GoRoute(
      path: '/worker-dashboard',
      redirect: (context, state) async {
        final prefs = await SharedPreferences.getInstance();
        final userJson = prefs.getString(Constants.userKey);
        if (userJson == null || !userJson.contains('"role":"worker"')) {
          return '/home';
        }
        return null;
      },
      builder: (_, __) => const WorkerDashboardScreen(),
    ),
    GoRoute(path: '/my-requests', builder: (_, __) => const MyRequestsScreen()),
    GoRoute(
      path: '/review/:serviceId',
      builder: (_, state) {
        final serviceId = int.parse(state.pathParameters['serviceId']!);
        return ReviewScreen(serviceId: serviceId);
      },
    ),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
  ],
);
