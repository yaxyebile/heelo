import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_view.dart';
import 'profile_view.dart';

/// Profile bottom-nav tab — rebuilds when auth changes (fixes stale guest screen).
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  static const profileTabIndex = 4;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
          return const ProfileView();
        }
        return _GuestProfilePrompt(
          onSignIn: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginView(returnTab: profileTabIndex),
            ),
          ),
        );
      },
    );
  }
}

class _GuestProfilePrompt extends StatelessWidget {
  final VoidCallback onSignIn;
  const _GuestProfilePrompt({required this.onSignIn});

  @override
  Widget build(BuildContext context) {
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
                child: const Icon(Icons.person_rounded,
                    size: 50, color: AppColors.primary),
              ),
              const SizedBox(height: 28),
              const Text(
                'Sign in to access Profile',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              const Text(
                'Create a free account or log in to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 14,
                    height: 1.5),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onSignIn,
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
  }
}
