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

final AutoDisposeStateProvider<bool> _obscurePasswordProvider =
    StateProvider.autoDispose<bool>((Ref ref) => true);
final AutoDisposeStateProvider<bool> _isSubmittingProvider =
    StateProvider.autoDispose<bool>((Ref ref) => false);
final AutoDisposeStateProvider<String?> _errorProvider =
    StateProvider.autoDispose<String?>((Ref ref) => null);

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      subtitle: 'Sign in to continue',
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppConstants.spacingXl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingMd),
                          TextField(
                            controller: _passwordController,
                            obscureText: obscurePassword,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    ref
                                        .read(_obscurePasswordProvider.notifier)
                                        .state = !obscurePassword,
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                            onSubmitted: (_) => _submit(context),
                          ),
                          const SizedBox(height: AppConstants.spacingSm),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () => context.push(AppRoutes.forgotPassword),
                              child: const Text('Forgot password?'),
                            ),
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
                                  : () => _submit(context),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: AppColors.white,
                                      ),
                                    )
                                  : const Text('Sign In'),
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingMd),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text(
                                "Don't have an account?",
                                style: AppTextStyles.body,
                              ),
                              TextButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => context.push(AppRoutes.signup),
                                child: const Text('Sign up'),
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

  Future<void> _submit(BuildContext context) async {
    final GoRouter router = GoRouter.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      ref.read(_errorProvider.notifier).state =
          'Please enter a valid email address.';
      return;
    }
    if (password.isEmpty) {
      ref.read(_errorProvider.notifier).state = 'Please enter your password.';
      return;
    }

    ref.read(_errorProvider.notifier).state = null;
    ref.read(_isSubmittingProvider.notifier).state = true;

    try {
      await ref
          .read(authServiceProvider)
          .signIn(email: email, password: password);
      router.refresh();
    } on supa.AuthException catch (error) {
      ref.read(_errorProvider.notifier).state = error.message;
    } catch (_) {
      ref.read(_errorProvider.notifier).state =
          'Unable to sign in right now. Please try again.';
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to sign in right now.')),
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
