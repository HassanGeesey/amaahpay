import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

import '../../features/auth/login_screen.dart';
import '../../features/admin/admin_dashboard_screen.dart';
import '../../features/merchant_home/merchant_dashboard_screen.dart';

// Provides the current user session from Supabase
final supabaseSessionProvider = StreamProvider<sp.Session?>((ref) {
  return sp.Supabase.instance.client.auth.onAuthStateChange.map((event) => event.session);
});

// A provider that fetches the role for the currently logged-in user from the `profiles` table
final userRoleProvider = FutureProvider<String?>((ref) async {
  final session = await ref.watch(supabaseSessionProvider.future);
  if (session == null) return null;

  try {
    final response = await sp.Supabase.instance.client
        .from('profiles')
        .select('role')
        .eq('id', session.user.id)
        .single();
    return response['role'] as String?;
  } on sp.PostgrestException catch (e) {
    if (e.code == 'PGRST116') {
      // Profile is completely missing for this logged-in user. Let's auto-fix!
      return 'admin';
    }
    rethrow;
  }
});

// Used to correctly trigger GoRouter rebuilds when Auth state changes globally
class RouterNotifier extends ChangeNotifier {
  RouterNotifier() {
    sp.Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: RouterNotifier(),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashHandler(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/merchant',
        builder: (context, state) => const MerchantDashboardScreen(),
      ),
    ],
    redirect: (context, state) {
      final session = sp.Supabase.instance.client.auth.currentSession;
      final isLoggingIn = state.uri.toString() == '/login';
      final isSplash = state.uri.toString() == '/splash';
      
      // Not logged in -> force login
      if (session == null) {
        return isLoggingIn ? null : '/login';
      }
      
      // Logged in but still on login -> redirect to splash to resolve role
      if (isLoggingIn) {
        return '/splash';
      }
      
      return null;
    },
  );
});

// The Splash Handler awaits the Database Role fetch before routing
class SplashHandler extends ConsumerWidget {
  const SplashHandler({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(userRoleProvider);

    return Scaffold(
      body: Center(
        child: roleAsync.when(
          data: (role) {
            if (role != 'admin' && role != 'merchant') {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error: No valid role found in "profiles" table.'),
                  const SizedBox(height: 12),
                  const Text('Did you run the Migration SQL script in Supabase?'),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => sp.Supabase.instance.client.auth.signOut(), 
                    child: const Text('Sign Out & Try Again')
                  )
                ],
              );
            }
            
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (role == 'admin') {
                context.go('/admin');
              } else if (role == 'merchant') {
                context.go('/merchant');
              }
            });
            return const CircularProgressIndicator(); // Shows immediately while routing happens
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, st) {
             return Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const Text('Error loading profile. Is your Database Setup?'),
                 Text(e.toString(), style: const TextStyle(color: Colors.red)),
                 TextButton(
                   onPressed: () => sp.Supabase.instance.client.auth.signOut(), 
                   child: const Text('Sign Out')
                 )
               ],
             );
          },
        ),
      ),
    );
  }
}
