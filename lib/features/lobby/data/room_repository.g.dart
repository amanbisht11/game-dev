// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseDatabaseHash() => r'2fc0d15b0ac43f604f8a71a90d71ac47842ff0bd';

/// See also [firebaseDatabase].
@ProviderFor(firebaseDatabase)
final firebaseDatabaseProvider = AutoDisposeProvider<FirebaseDatabase>.internal(
  firebaseDatabase,
  name: r'firebaseDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseDatabaseRef = AutoDisposeProviderRef<FirebaseDatabase>;
String _$roomRepositoryHash() => r'831f94aa34bbb693fa29095bc142822430525676';

/// See also [roomRepository].
@ProviderFor(roomRepository)
final roomRepositoryProvider = AutoDisposeProvider<RoomRepository>.internal(
  roomRepository,
  name: r'roomRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$roomRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RoomRepositoryRef = AutoDisposeProviderRef<RoomRepository>;
String _$roomStreamHash() => r'900caa056dfd46a878e2299aebf221de281a2441';

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

/// See also [roomStream].
@ProviderFor(roomStream)
const roomStreamProvider = RoomStreamFamily();

/// See also [roomStream].
class RoomStreamFamily extends Family<AsyncValue<RoomModel?>> {
  /// See also [roomStream].
  const RoomStreamFamily();

  /// See also [roomStream].
  RoomStreamProvider call(String roomCode) {
    return RoomStreamProvider(roomCode);
  }

  @override
  RoomStreamProvider getProviderOverride(
    covariant RoomStreamProvider provider,
  ) {
    return call(provider.roomCode);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'roomStreamProvider';
}

/// See also [roomStream].
class RoomStreamProvider extends AutoDisposeStreamProvider<RoomModel?> {
  /// See also [roomStream].
  RoomStreamProvider(String roomCode)
    : this._internal(
        (ref) => roomStream(ref as RoomStreamRef, roomCode),
        from: roomStreamProvider,
        name: r'roomStreamProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$roomStreamHash,
        dependencies: RoomStreamFamily._dependencies,
        allTransitiveDependencies: RoomStreamFamily._allTransitiveDependencies,
        roomCode: roomCode,
      );

  RoomStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roomCode,
  }) : super.internal();

  final String roomCode;

  @override
  Override overrideWith(
    Stream<RoomModel?> Function(RoomStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoomStreamProvider._internal(
        (ref) => create(ref as RoomStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roomCode: roomCode,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<RoomModel?> createElement() {
    return _RoomStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoomStreamProvider && other.roomCode == roomCode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roomCode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RoomStreamRef on AutoDisposeStreamProviderRef<RoomModel?> {
  /// The parameter `roomCode` of this provider.
  String get roomCode;
}

class _RoomStreamProviderElement
    extends AutoDisposeStreamProviderElement<RoomModel?>
    with RoomStreamRef {
  _RoomStreamProviderElement(super.provider);

  @override
  String get roomCode => (origin as RoomStreamProvider).roomCode;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
