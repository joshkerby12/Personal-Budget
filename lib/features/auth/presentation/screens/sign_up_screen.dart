import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../providers/auth_provider.dart';

final AutoDisposeStateProvider<String> _fullNameProvider =
    StateProvider.autoDispose<String>((Ref ref) => '');
final AutoDisposeStateProvider<String> _emailProvider =
    StateProvider.autoDispose<String>((Ref ref) => '');
final AutoDisposeStateProvider<String> _passwordProvider =
    StateProvider.autoDispose<String>((Ref ref) => '');
final AutoDisposeStateProvider<String> _confirmPasswordProvider =
    StateProvider.autoDispose<String>((Ref ref) => '');
final AutoDisposeStateProvider<bool> _obscurePasswordProvider =
    StateProvider.autoDispose<bool>((Ref ref) => true);
final AutoDisposeStateProvider<bool> _isSubmittingProvider =
    StateProvider.autoDispose<bool>((Ref ref) => false);
final AutoDisposeStateProvider<String?> _errorProvider =
    StateProvider.autoDispose<String?>((Ref ref) => null);

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isSubmitting = ref.watch(_isSubmittingProvider);
    final bool obscurePassword = ref.watch(_obscurePasswordProvider);
    final String? errorMessage = ref.watch(_errorProvider);

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const _AuthHeader(
                      title: 'Kerby Family Budget',
                      subtitle: 'Create your account',
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppConstants.spacingXl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          TextField(
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                            ),
                            onChanged: (String value) =>
                                ref.read(_fullNameProvider.notifier).state =
                                    value,
                          ),
                          const SizedBox(height: AppConstants.spacingMd),
                          TextField(
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            onChanged: (String value) =>
                                ref.read(_emailProvider.notifier).state = value,
                          ),
                          const SizedBox(height: AppConstants.spacingMd),
                          TextField(
                            obscureText: obscurePassword,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    ref
                                            .read(
                                              _obscurePasswordProvider.notifier,
                                            )
                                            .state =
                                        !obscurePassword,
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                            onChanged: (String value) =>
                                ref.read(_passwordProvider.notifier).state =
                                    value,
                          ),
                          const SizedBox(height: AppConstants.spacingMd),
                          TextField(
                            obscureText: obscurePassword,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: 'Confirm Password',
                            ),
                            onChanged: (String value) =>
                                ref
                                        .read(_confirmPasswordProvider.notifier)
                                        .state =
                                    value,
                            onSubmitted: (_) => _submit(context, ref),
                          ),
                          if (errorMessage != null) ...<Widget>[
                            const SizedBox(height: AppConstants.spacingSm),
                            ErrorView(message: errorMessage),
                          ],
                          const SizedBox(height: AppConstants.spacingMd),
                          SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () => _submit(context, ref),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: AppColors.white,
                                      ),
                                    )
                                  : const Text('Create Account'),
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingMd),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text(
                                'Already have an account?',
                                style: AppTextStyles.body,
                              ),
                              TextButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => context.go(AppRoutes.login),
                                child: const Text('Sign in'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final GoRouter router = GoRouter.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final String fullName = ref.read(_fullNameProvider).trim();
    final String email = ref.read(_emailProvider).trim();
    final String password = ref.read(_passwordProvider);
    final String confirmPassword = ref.read(_confirmPasswordProvider);

    if (fullName.isEmpty) {
      ref.read(_errorProvider.notifier).state = 'Please enter your full name.';
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      ref.read(_errorProvider.notifier).state =
          'Please enter a valid email address.';
      return;
    }
    if (password.length < 6) {
      ref.read(_errorProvider.notifier).state =
          'Password must be at least 6 characters.';
      return;
    }
    if (password != confirmPassword) {
      ref.read(_errorProvider.notifier).state = 'Passwords do not match.';
      return;
    }

    ref.read(_errorProvider.notifier).state = null;
    ref.read(_isSubmittingProvider.notifier).state = true;

    try {
      await ref
          .read(authServiceProvider)
          .signUp(email: email, password: password, fullName: fullName);
      messenger.showSnackBar(
        const SnackBar(content: Text('Account created successfully.')),
      );
      router.refresh();
    } on supa.AuthException catch (error) {
      ref.read(_errorProvider.notifier).state = error.message;
    } catch (_) {
      ref.read(_errorProvider.notifier).state =
          'Unable to create your account right now.';
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to create your account.')),
      );
    } finally {
      ref.read(_isSubmittingProvider.notifier).state = false;
    }
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[AppColors.navy, AppColors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.spacingSm),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: AppTextStyles.cardTitle.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: AppConstants.spacingXs),
          Text(
            subtitle,
            style: AppTextStyles.body.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}
