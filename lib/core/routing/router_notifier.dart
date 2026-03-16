import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/supabase_client_provider.dart';
import 'app_routes.dart';

final Provider<RouterNotifier> routerNotifierProvider =
    Provider<RouterNotifier>((Ref ref) {
      final RouterNotifier notifier = RouterNotifier(ref);
      ref.onDispose(notifier.dispose);
      return notifier;
    });

class RouterNotifier implements Listenable {
  RouterNotifier(Ref ref) : _supabaseClient = ref.read(supabaseClientProvider) {
    _session = _supabaseClient.auth.currentSession;
    _authStateSubscription = _supabaseClient.auth.onAuthStateChange.listen((
      AuthState event,
    ) {
      _session = event.session;
      _cachedHasOrganization = null;
      _notifyListeners();
    });
  }

  final SupabaseClient _supabaseClient;
  final Set<VoidCallback> _listeners = <VoidCallback>{};

  Session? _session;
  bool? _cachedHasOrganization;
  StreamSubscription<AuthState>? _authStateSubscription;

  Future<String?> redirect(BuildContext context, GoRouterState state) async {
    final bool isLoggedIn = _session != null;
    final String location = state.matchedLocation;
    final bool isLogin = location == AppRoutes.login;
    final bool isSignup = location == AppRoutes.signup;
    final bool isForgotPassword = location == AppRoutes.forgotPassword;
    final bool isAuthRoute = isLogin || isSignup || isForgotPassword;
    final bool isOnboarding = location == AppRoutes.onboarding;

    if (!isLoggedIn) {
      return isAuthRoute ? null : AppRoutes.login;
    }

    final bool hasOrganization = await _userHasOrganization();
    if (!hasOrganization) {
      return isOnboarding ? null : AppRoutes.onboarding;
    }

    if (location == AppRoutes.root || isAuthRoute || isOnboarding) {
      return AppRoutes.dashboard;
    }

    return null;
  }

  Future<bool> _userHasOrganization() async {
    final bool? cachedValue = _cachedHasOrganization;
    if (cachedValue != null) {
      return cachedValue;
    }

    final String? userId = _session?.user.id;
    if (userId == null) {
      _cachedHasOrganization = false;
      return false;
    }

    try {
      final dynamic rows = await _supabaseClient
          .from('org_members')
          .select('org_id')
          .eq('profile_id', userId)
          .limit(1);
      final bool hasOrganization = (rows as List<dynamic>).isNotEmpty;
      _cachedHasOrganization = hasOrganization;
      return hasOrganization;
    } catch (_) {
      _cachedHasOrganization = false;
      return false;
    }
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final VoidCallback listener in _listeners.toList()) {
      listener();
    }
  }

  void dispose() {
    _authStateSubscription?.cancel();
  }
}
