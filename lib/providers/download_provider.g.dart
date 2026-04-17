// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$downloadNotifierHash() => r'134d7d8300690124cbff4d7e9d4be5b7337ee12a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$DownloadNotifier
    extends BuildlessAutoDisposeNotifier<DownloadState> {
  late final String downloadId;

  DownloadState build(
    String downloadId,
  );
}

/// See also [DownloadNotifier].
@ProviderFor(DownloadNotifier)
const downloadNotifierProvider = DownloadNotifierFamily();

/// See also [DownloadNotifier].
class DownloadNotifierFamily extends Family<DownloadState> {
  /// See also [DownloadNotifier].
  const DownloadNotifierFamily();

  /// See also [DownloadNotifier].
  DownloadNotifierProvider call(
    String downloadId,
  ) {
    return DownloadNotifierProvider(
      downloadId,
    );
  }

  @override
  DownloadNotifierProvider getProviderOverride(
    covariant DownloadNotifierProvider provider,
  ) {
    return call(
      provider.downloadId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'downloadNotifierProvider';
}

/// See also [DownloadNotifier].
class DownloadNotifierProvider
    extends AutoDisposeNotifierProviderImpl<DownloadNotifier, DownloadState> {
  /// See also [DownloadNotifier].
  DownloadNotifierProvider(
    String downloadId,
  ) : this._internal(
          () => DownloadNotifier()..downloadId = downloadId,
          from: downloadNotifierProvider,
          name: r'downloadNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$downloadNotifierHash,
          dependencies: DownloadNotifierFamily._dependencies,
          allTransitiveDependencies:
              DownloadNotifierFamily._allTransitiveDependencies,
          downloadId: downloadId,
        );

  DownloadNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.downloadId,
  }) : super.internal();

  final String downloadId;

  @override
  DownloadState runNotifierBuild(
    covariant DownloadNotifier notifier,
  ) {
    return notifier.build(
      downloadId,
    );
  }

  @override
  Override overrideWith(DownloadNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: DownloadNotifierProvider._internal(
        () => create()..downloadId = downloadId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        downloadId: downloadId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<DownloadNotifier, DownloadState>
      createElement() {
    return _DownloadNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DownloadNotifierProvider && other.downloadId == downloadId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, downloadId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DownloadNotifierRef on AutoDisposeNotifierProviderRef<DownloadState> {
  /// The parameter `downloadId` of this provider.
  String get downloadId;
}

class _DownloadNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<DownloadNotifier, DownloadState>
    with DownloadNotifierRef {
  _DownloadNotifierProviderElement(super.provider);

  @override
  String get downloadId => (origin as DownloadNotifierProvider).downloadId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
