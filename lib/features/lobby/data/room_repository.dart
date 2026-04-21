import 'package:firebase_database/firebase_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/room_model.dart';
import '../../../core/utils/room_code_generator.dart';

part 'room_repository.g.dart';

class RoomRepository {
  final FirebaseDatabase _db;
  RoomRepository(this._db);

  Future<String> createRoom(PlayerModel host, bool isPrivate) async {
    final roomCode = generateRoomCode();
    final room = RoomModel(
      roomCode: roomCode,
      status: 'waiting',
      createdAt: DateTime.now(),
      isPrivate: isPrivate,
      player1: host,
    );

    await _db.ref('rooms/$roomCode').set(room.toJson());
    return roomCode;
  }

  Future<void> joinRoom(String roomCode, PlayerModel guest) async {
    final ref = _db.ref('rooms/$roomCode/players/player2');
    await ref.set(guest.toJson());
  }

  /// Delete the entire room (used when host leaves waiting screen)
  Future<void> deleteRoom(String roomCode) async {
    await _db.ref('rooms/$roomCode').remove();
  }

  /// Remove player2 from the room (used when guest leaves waiting screen)
  Future<void> leaveRoom(String roomCode) async {
    await _db.ref('rooms/$roomCode/players/player2').remove();
  }

  Stream<RoomModel?> watchRoom(String roomCode) {
    return _db.ref('rooms/$roomCode').onValue.map((event) {
      if (event.snapshot.value != null) {
        return RoomModel.fromJson(
          Map<String, dynamic>.from(event.snapshot.value as Map),
        );
      }
      return null;
    });
  }
}

@riverpod
FirebaseDatabase firebaseDatabase(FirebaseDatabaseRef ref) {
  return FirebaseDatabase.instance;
}

@riverpod
RoomRepository roomRepository(RoomRepositoryRef ref) {
  return RoomRepository(ref.watch(firebaseDatabaseProvider));
}

@riverpod
Stream<RoomModel?> roomStream(RoomStreamRef ref, String roomCode) {
  return ref.watch(roomRepositoryProvider).watchRoom(roomCode);
}
