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

final AutoDisposeStateProvider<String> _emailProvider =
    StateProvider.autoDispose<String>((Ref ref) => '');
final AutoDisposeStateProvider<bool> _isSubmittingProvider =
    StateProvider.autoDispose<bool>((Ref ref) => false);
final AutoDisposeStateProvider<bool> _showSuccessStateProvider =
    StateProvider.autoDispose<bool>((Ref ref) => false);
final AutoDisposeStateProvider<String?> _errorProvider =
    StateProvider.autoDispose<String?>((Ref ref) => null);

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isSubmitting = ref.watch(_isSubmittingProvider);
    final bool showSuccessState = ref.watch(_showSuccessStateProvider);
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
                      subtitle: 'Reset your password',
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppConstants.spacingXl),
                      child: showSuccessState
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: AppColors.green,
                                  size: 32,
                                ),
                                const SizedBox(height: AppConstants.spacingSm),
                                const Text(
                                  'Check your email for a reset link.',
                                  style: AppTextStyles.body,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppConstants.spacingLg),
                                ElevatedButton(
                                  onPressed: () => context.go(AppRoutes.login),
                                  child: const Text('Back to Sign In'),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                TextField(
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.done,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                  ),
                                  onChanged: (String value) =>
                                      ref.read(_emailProvider.notifier).state =
                                          value,
                                  onSubmitted: (_) => _submit(context, ref),
                                ),
                                if (errorMessage != null) ...<Widget>[
                                  const SizedBox(
                                    height: AppConstants.spacingSm,
                                  ),
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
                                        : const Text('Send Reset Link'),
                                  ),
                                ),
                                const SizedBox(height: AppConstants.spacingSm),
                                TextButton(
                                  onPressed: isSubmitting
                                      ? null
                                      : () => context.go(AppRoutes.login),
                                  child: const Text('Back to sign in'),
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

    final String email = ref.read(_emailProvider).trim();
    if (email.isEmpty || !email.contains('@')) {
      ref.read(_errorProvider.notifier).state =
          'Please enter a valid email address.';
      return;
    }

    ref.read(_errorProvider.notifier).state = null;
    ref.read(_isSubmittingProvider.notifier).state = true;

    try {
      await ref.read(authServiceProvider).sendPasswordReset(email: email);
      ref.read(_showSuccessStateProvider.notifier).state = true;
      router.refresh();
    } on supa.AuthException catch (error) {
      ref.read(_errorProvider.notifier).state = error.message;
    } catch (_) {
      ref.read(_errorProvider.notifier).state =
          'Unable to send reset email right now.';
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to send reset email right now.')),
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
