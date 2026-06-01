import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_view.dart';
import '../chat/chat_screen.dart';

class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  static const messagesTabIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
          return const ChatScreen(
            otherUserId: 'admin',
            otherUserName: 'Support',
            rootTab: true,
          );
        }
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chat_bubble_rounded,
                        size: 50, color: AppColors.primary),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Sign in to access Messages',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const LoginView(returnTab: messagesTabIndex),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 52),
                    ),
                    child: const Text('Sign In Now'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
