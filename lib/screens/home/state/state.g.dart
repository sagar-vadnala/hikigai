// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$photosStateNotifierHash() =>
    r'ba6f8e45167fd24792e407457485223ec79d4763';

/// See also [PhotosStateNotifier].
@ProviderFor(PhotosStateNotifier)
final photosStateNotifierProvider =
    AutoDisposeNotifierProvider<PhotosStateNotifier, PhotosState>.internal(
  PhotosStateNotifier.new,
  name: r'photosStateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$photosStateNotifierHash,
  dependencies: <ProviderOrFamily>[apiProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    apiProvider,
    ...?apiProvider.allTransitiveDependencies
  },
);

typedef _$PhotosStateNotifier = AutoDisposeNotifier<PhotosState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
