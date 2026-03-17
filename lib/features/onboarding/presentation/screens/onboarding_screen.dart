import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/routing/router_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../providers/onboarding_provider.dart';

enum _OnboardingStep { choosePath, createHousehold, joinHousehold }

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _inviteCodeController = TextEditingController();

  _OnboardingStep _step = _OnboardingStep.choosePath;
  String? _createError;
  String? _joinError;
  bool _isJoining = false;

  @override
  void dispose() {
    _orgNameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<void> state = ref.watch(onboardingControllerProvider);
    final bool isLoading = state.isLoading || _isJoining;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _OnboardingHeader(
                      title: 'Kerby Family Budget',
                      subtitle: _subtitleForStep(_step),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppConstants.spacingXl),
                      child: _buildStepContent(context, isLoading),
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

  Widget _buildStepContent(BuildContext context, bool isLoading) {
    switch (_step) {
      case _OnboardingStep.choosePath:
        return _buildChoosePathStep();
      case _OnboardingStep.createHousehold:
        return _buildCreateHouseholdStep(context, isLoading);
      case _OnboardingStep.joinHousehold:
        return _buildJoinHouseholdStep(context, isLoading);
    }
  }

  Widget _buildChoosePathStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text(
          'Choose how you want to set up your household.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: AppConstants.spacingMd),
        SizedBox(
          height: 44,
          child: ElevatedButton(
            onPressed: () => setState(() {
              _step = _OnboardingStep.createHousehold;
              _createError = null;
            }),
            child: const Text('Create a New Household'),
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        SizedBox(
          height: 44,
          child: OutlinedButton(
            onPressed: () => setState(() {
              _step = _OnboardingStep.joinHousehold;
              _joinError = null;
            }),
            child: const Text('Join an Existing Household'),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateHouseholdStep(BuildContext context, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: _orgNameController,
          enabled: !isLoading,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Household Name',
            helperText: 'This is your household or family name.',
          ),
          onSubmitted: (_) => _submitCreate(context),
        ),
        if (_createError != null) ...<Widget>[
          const SizedBox(height: AppConstants.spacingSm),
          ErrorView(message: _createError!),
        ],
        const SizedBox(height: AppConstants.spacingMd),
        SizedBox(
          height: 44,
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _submitCreate(context),
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppColors.white,
                    ),
                  )
                : const Text('Create Household'),
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: isLoading
                ? null
                : () => setState(() {
                    _step = _OnboardingStep.choosePath;
                    _createError = null;
                  }),
            child: const Text('Back'),
          ),
        ),
      ],
    );
  }

  Widget _buildJoinHouseholdStep(BuildContext context, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: _inviteCodeController,
          enabled: !isLoading,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.characters,
          style: AppTextStyles.body.copyWith(
            fontFamily: 'monospace',
            letterSpacing: 2,
          ),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
            LengthLimitingTextInputFormatter(6),
            const _UppercaseTextFormatter(),
          ],
          decoration: const InputDecoration(
            labelText: 'Invite Code',
            helperText: 'Enter the 6-character code from your household owner.',
          ),
          onSubmitted: (_) => _submitJoin(context),
        ),
        if (_joinError != null) ...<Widget>[
          const SizedBox(height: AppConstants.spacingSm),
          ErrorView(message: _joinError!),
        ],
        const SizedBox(height: AppConstants.spacingMd),
        SizedBox(
          height: 44,
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _submitJoin(context),
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppColors.white,
                    ),
                  )
                : const Text('Join Household'),
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: isLoading
                ? null
                : () => setState(() {
                    _step = _OnboardingStep.choosePath;
                    _joinError = null;
                  }),
            child: const Text('Back'),
          ),
        ),
      ],
    );
  }

  String _subtitleForStep(_OnboardingStep step) {
    switch (step) {
      case _OnboardingStep.choosePath:
        return 'Set up your household';
      case _OnboardingStep.createHousehold:
        return 'Create a new household';
      case _OnboardingStep.joinHousehold:
        return 'Join an existing household';
    }
  }

  Future<void> _submitCreate(BuildContext context) async {
    final GoRouter router = GoRouter.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final String name = _orgNameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _createError = 'Please enter a household name.';
      });
      return;
    }

    setState(() {
      _createError = null;
    });

    try {
      await ref
          .read(onboardingControllerProvider.notifier)
          .createOrganization(name);
      ref.read(routerNotifierProvider).clearOrgCache();
      router.refresh();
    } catch (error) {
      final String message = _errorMessageFor(error);
      if (!mounted) {
        return;
      }
      setState(() {
        _createError = message;
      });
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _submitJoin(BuildContext context) async {
    final GoRouter router = GoRouter.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final String code = _inviteCodeController.text.trim().toUpperCase();
    if (code.length != 6) {
      setState(() {
        _joinError = 'Enter a valid 6-character invite code.';
      });
      return;
    }

    final String? userId = ref
        .read(supabaseClientProvider)
        .auth
        .currentUser
        ?.id;
    if (userId == null) {
      setState(() {
        _joinError = 'You must be signed in to join a household.';
      });
      return;
    }

    setState(() {
      _joinError = null;
      _isJoining = true;
    });

    try {
      final ({String orgId, String orgName})? org = await ref
          .read(onboardingControllerProvider.notifier)
          .findOrgByInviteCode(code);

      if (!mounted) {
        return;
      }

      if (org == null) {
        const String message =
            'No household found with that code. Check the code and try again.';
        setState(() {
          _joinError = message;
        });
        messenger.showSnackBar(const SnackBar(content: Text(message)));
        return;
      }

      if (!context.mounted) {
        return;
      }

      final bool? shouldJoin = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Join household?'),
            content: Text('Join "${org.orgName}" with code $code?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Join'),
              ),
            ],
          );
        },
      );

      if (shouldJoin != true) {
        return;
      }

      await ref
          .read(onboardingControllerProvider.notifier)
          .joinOrganization(orgId: org.orgId, userId: userId);

      ref.read(routerNotifierProvider).clearOrgCache();
      router.refresh();
    } catch (error) {
      final String message = _errorMessageFor(error);
      if (!mounted) {
        return;
      }
      setState(() {
        _joinError = message;
      });
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }

  String _errorMessageFor(Object error) {
    if (error is ArgumentError) {
      return error.message?.toString() ??
          'Please check your input and try again.';
    }
    if (error is PostgrestException && error.message.isNotEmpty) {
      return error.message;
    }
    return 'Unable to continue right now. Please try again.';
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({required this.title, required this.subtitle});

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

class _UppercaseTextFormatter extends TextInputFormatter {
  const _UppercaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String upper = newValue.text.toUpperCase();
    return newValue.copyWith(
      text: upper,
      selection: TextSelection.collapsed(offset: upper.length),
    );
  }
}
