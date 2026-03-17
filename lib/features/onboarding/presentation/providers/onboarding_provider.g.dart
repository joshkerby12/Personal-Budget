// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orgServiceHash() => r'53b1b1bf065ab80b3ada41ce07123eb77823ab92';

/// See also [orgService].
@ProviderFor(orgService)
final orgServiceProvider = Provider<OrgService>.internal(
  orgService,
  name: r'orgServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$orgServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrgServiceRef = ProviderRef<OrgService>;
String _$inviteServiceHash() => r'329da5ae96594ef54e54cd258e2a7aa9bfaf6be4';

/// See also [inviteService].
@ProviderFor(inviteService)
final inviteServiceProvider = Provider<InviteService>.internal(
  inviteService,
  name: r'inviteServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inviteServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InviteServiceRef = ProviderRef<InviteService>;
String _$onboardingControllerHash() =>
    r'df1e29c1330939912025c800055b98a2184dedb7';

/// See also [OnboardingController].
@ProviderFor(OnboardingController)
final onboardingControllerProvider =
    AutoDisposeNotifierProvider<
      OnboardingController,
      AsyncValue<void>
    >.internal(
      OnboardingController.new,
      name: r'onboardingControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$onboardingControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OnboardingController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
