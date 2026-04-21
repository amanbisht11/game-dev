import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/data/auth_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../data/room_repository.dart';
import '../domain/room_model.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    final user = ref.read(authStateProvider).value;
    final profile = ref.read(userProfileProvider).value;

    debugPrint('[LobbyScreen] _createRoom called');
    debugPrint('[LobbyScreen] user: ${user?.uid}');
    debugPrint('[LobbyScreen] profile: ${profile?.name}');

    if (user == null) {
      _showError('Not authenticated. Please restart the app.');
      return;
    }

    if (profile == null) {
      _showError('Profile not loaded yet. Please wait a moment and try again.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final host = PlayerModel(
        uid: user.uid,
        name: profile.name,
        avatarUrl: profile.avatarUrl,
      );
      debugPrint('[LobbyScreen] Creating room with host: ${host.name}');
      final roomCode = await ref.read(roomRepositoryProvider).createRoom(host, true);
      debugPrint('[LobbyScreen] Room created: $roomCode');
      if (mounted) {
        context.push('/lobby/waiting/$roomCode');
      }
    } catch (e, stackTrace) {
      debugPrint('[LobbyScreen] Error creating room: $e');
      debugPrint('[LobbyScreen] Stack: $stackTrace');
      if (mounted) {
        _showError('Failed to create room: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _joinRoom() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      _showError('Please enter a valid 6-character room code.');
      return;
    }

    final user = ref.read(authStateProvider).value;
    final profile = ref.read(userProfileProvider).value;
    if (user == null || profile == null) {
      _showError('Profile still loading. Please try again.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final guest = PlayerModel(
        uid: user.uid,
        name: profile.name,
        avatarUrl: profile.avatarUrl,
      );
      await ref.read(roomRepositoryProvider).joinRoom(code, guest);
      if (mounted) {
        context.push('/lobby/waiting/$code');
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to join room: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    setState(() => _errorText = msg);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.player2Red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GAME LOBBY')),
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 600 ? constraints.maxWidth * 0.15 : 24,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LobbyCard(
                    title: 'HOST A GAME',
                    subtitle: 'Create a private room and invite a friend',
                    icon: Icons.add_box_rounded,
                    color: AppColors.player1Blue,
                    isLoading: _isLoading,
                    onTap: _isLoading ? null : _createRoom,
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR', style: TextStyle(color: AppColors.textGrey)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'JOIN WITH CODE',
                          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _codeController,
                          textAlign: TextAlign.center,
                          maxLength: 6,
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(fontSize: 22, letterSpacing: 6, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            hintText: 'CODE',
                            counterText: '',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _joinRoom,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.player2Red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('JOIN ROOM'),
                        ),
                      ],
                    ),
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: 16),
                    Text(_errorText!, style: const TextStyle(color: AppColors.player2Red, fontSize: 12)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LobbyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isLoading;

  const _LobbyCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
              child: isLoading
                  ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}
