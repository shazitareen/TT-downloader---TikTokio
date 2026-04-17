// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tiktok_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tikTokNotifierHash() => r'607c0f9467bd1a0e7a55465722852041315910dc';

/// See also [TikTokNotifier].
@ProviderFor(TikTokNotifier)
final tikTokNotifierProvider = AutoDisposeNotifierProvider<TikTokNotifier,
    AsyncValue<TikTokVideoInfo?>>.internal(
  TikTokNotifier.new,
  name: r'tikTokNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tikTokNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TikTokNotifier = AutoDisposeNotifier<AsyncValue<TikTokVideoInfo?>>;
String _$tikTokSearchNotifierHash() =>
    r'76958533c957a300739c2995f294afa1600d8e02';

/// See also [TikTokSearchNotifier].
@ProviderFor(TikTokSearchNotifier)
final tikTokSearchNotifierProvider = AutoDisposeNotifierProvider<
    TikTokSearchNotifier, AsyncValue<List<TikTokVideoInfo>>>.internal(
  TikTokSearchNotifier.new,
  name: r'tikTokSearchNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tikTokSearchNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TikTokSearchNotifier
    = AutoDisposeNotifier<AsyncValue<List<TikTokVideoInfo>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
