import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/navigation/app_navigator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/notification_provider.dart';
import '../../core/widgets/custom_text_field.dart';
import 'signup_view.dart';
import '../../core/widgets/colorful_hello.dart';
import '../../core/theme/app_theme.dart';

class LoginView extends StatefulWidget {
  /// Bottom-nav tab to show after login (0=Home … 4=Profile).
  final int returnTab;
  const LoginView({super.key, this.returnTab = 0});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final market = context.read<MarketplaceProvider>();
    final notifications = context.read<NotificationProvider>();

    final error = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    await market.refresh();
    final uid = authProvider.currentUser?.id;
    if (uid != null) {
      await market.loadWishlist(uid);
      await notifications.load(uid);
    }

    // Full shell rebuild — same effect as manual refresh (fixes stale Profile tab).
    AppNavigator.resetToHome(tab: widget.returnTab);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                // Logo
                const Center(
                  child: Column(
                    children: [
                      ColorfulHello(fontSize: 60),
                      Text(
                        "Buy. Sell. Anything. Anywhere.",
                        style: TextStyle(color: AppColors.textGray, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                const Text(
                  "Welcome back 👋",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Sign in to your account to continue",
                  style: TextStyle(color: AppColors.textGray, fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 36),
                CustomTextField(
                  label: "Email/Phone",
                  hint: "name@email.com or 61XXXXXXX",
                  prefixIcon: Icons.person_outline_rounded,
                  controller: _emailController,
                  validator: (v) => v == null || v.isEmpty ? "Email/Phone is required" : null,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: "Password",
                  hint: "Enter your password",
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: _obscurePassword,
                  controller: _passwordController,
                  suffixIcon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  onSuffixPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  validator: (v) => v == null || v.isEmpty ? "Password is required" : null,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: AppColors.darkBlue, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Sign In Button
                authProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          "Sign In",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                const SizedBox(height: 36),
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1.5)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text("or continue with", style: TextStyle(color: AppColors.textGray, fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1.5)),
                  ],
                ),
                const SizedBox(height: 24),
                // Social Button placeholder
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200, width: 1.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.g_mobiledata_rounded, color: Color(0xFF4285F4), size: 30),
                        SizedBox(width: 8),
                        Text("Continue with Google", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.darkBlue)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?", style: TextStyle(color: AppColors.textGray, fontWeight: FontWeight.w500)),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupView())),
                        child: const Text("Sign Up", style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w800, fontSize: 15)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
