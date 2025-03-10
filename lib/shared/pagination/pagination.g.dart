// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$paginationStateNotifierHash() =>
    r'bba45c26f041ae3ad4f3744575da15dc04909668';

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

abstract class _$PaginationStateNotifier
    extends BuildlessAutoDisposeNotifier<PaginationState> {
  late final Future<PaginationActionResponse> Function(int) fetchMoreData;

  PaginationState build(
    Future<PaginationActionResponse> Function(int) fetchMoreData,
  );
}

/// See also [PaginationStateNotifier].
@ProviderFor(PaginationStateNotifier)
const paginationStateNotifierProvider = PaginationStateNotifierFamily();

/// See also [PaginationStateNotifier].
class PaginationStateNotifierFamily extends Family<PaginationState> {
  /// See also [PaginationStateNotifier].
  const PaginationStateNotifierFamily();

  /// See also [PaginationStateNotifier].
  PaginationStateNotifierProvider call(
    Future<PaginationActionResponse> Function(int) fetchMoreData,
  ) {
    return PaginationStateNotifierProvider(
      fetchMoreData,
    );
  }

  @override
  PaginationStateNotifierProvider getProviderOverride(
    covariant PaginationStateNotifierProvider provider,
  ) {
    return call(
      provider.fetchMoreData,
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
  String? get name => r'paginationStateNotifierProvider';
}

/// See also [PaginationStateNotifier].
class PaginationStateNotifierProvider extends AutoDisposeNotifierProviderImpl<
    PaginationStateNotifier, PaginationState> {
  /// See also [PaginationStateNotifier].
  PaginationStateNotifierProvider(
    Future<PaginationActionResponse> Function(int) fetchMoreData,
  ) : this._internal(
          () => PaginationStateNotifier()..fetchMoreData = fetchMoreData,
          from: paginationStateNotifierProvider,
          name: r'paginationStateNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$paginationStateNotifierHash,
          dependencies: PaginationStateNotifierFamily._dependencies,
          allTransitiveDependencies:
              PaginationStateNotifierFamily._allTransitiveDependencies,
          fetchMoreData: fetchMoreData,
        );

  PaginationStateNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.fetchMoreData,
  }) : super.internal();

  final Future<PaginationActionResponse> Function(int) fetchMoreData;

  @override
  PaginationState runNotifierBuild(
    covariant PaginationStateNotifier notifier,
  ) {
    return notifier.build(
      fetchMoreData,
    );
  }

  @override
  Override overrideWith(PaginationStateNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: PaginationStateNotifierProvider._internal(
        () => create()..fetchMoreData = fetchMoreData,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        fetchMoreData: fetchMoreData,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<PaginationStateNotifier, PaginationState>
      createElement() {
    return _PaginationStateNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PaginationStateNotifierProvider &&
        other.fetchMoreData == fetchMoreData;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, fetchMoreData.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PaginationStateNotifierRef
    on AutoDisposeNotifierProviderRef<PaginationState> {
  /// The parameter `fetchMoreData` of this provider.
  Future<PaginationActionResponse> Function(int) get fetchMoreData;
}

class _PaginationStateNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<PaginationStateNotifier,
        PaginationState> with PaginationStateNotifierRef {
  _PaginationStateNotifierProviderElement(super.provider);

  @override
  Future<PaginationActionResponse> Function(int) get fetchMoreData =>
      (origin as PaginationStateNotifierProvider).fetchMoreData;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
