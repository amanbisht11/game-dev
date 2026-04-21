import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/user_model.dart';
import '../../auth/data/auth_repository.dart';

part 'profile_repository.g.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;
  ProfileRepository(this._firestore);

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> createUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toJson());
  }

  Stream<UserModel?> watchUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    });
  }

  Future<void> updateProfile({
    required String uid,
    required String name,
    required String country,
    String? favoriteTeam,
  }) async {
    final Map<String, dynamic> data = {
      'name': name,
      'country': country,
    };
    if (favoriteTeam != null) {
      data['favoriteTeam'] = favoriteTeam;
    }
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<void> updateStats({
    required String uid,
    required String roomCode,
    required bool won,
    required int xpGained,
  }) async {
    final gameRef = _firestore.collection('users').doc(uid).collection('processedGames').doc(roomCode);
    final userRef = _firestore.collection('users').doc(uid);

    await _firestore.runTransaction((transaction) async {
      final gameDoc = await transaction.get(gameRef);
      if (gameDoc.exists) return; // Already processed

      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) return;

      final data = userDoc.data()!;
      final currentWins = data['wins'] ?? 0;
      final currentLosses = data['losses'] ?? 0;
      final currentMatches = data['totalMatches'] ?? 0;
      final currentXP = data['xp'] ?? 0;
      
      int newXP = currentXP + xpGained;
      int newLevel = (newXP / 100).floor() + 1;

      transaction.set(gameRef, {'processedAt': FieldValue.serverTimestamp()});
      transaction.update(userRef, {
        'totalMatches': currentMatches + 1,
        'wins': won ? currentWins + 1 : currentWins,
        'losses': won ? currentLosses : currentLosses + 1,
        'xp': newXP,
        'level': newLevel,
      });
    });
  }
}

@riverpod
FirebaseFirestore firebaseFirestore(FirebaseFirestoreRef ref) {
  return FirebaseFirestore.instance;
}

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepository(ref.watch(firebaseFirestoreProvider));
}

@riverpod
Stream<UserModel?> userProfile(UserProfileRef ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(profileRepositoryProvider).watchUserProfile(user.uid);
}
