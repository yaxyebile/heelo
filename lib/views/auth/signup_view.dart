import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/navigation/app_navigator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../models/user_role.dart';
import '../../core/widgets/colorful_hello.dart';
import '../../core/theme/app_theme.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _nameController = TextEditingController();
  String _phoneNumber = "";
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final error = await auth.signup(
        name: _nameController.text.trim(),
        phone: _phoneNumber,
        password: _passwordController.text,
      );
      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else if (mounted) {
        await Provider.of<MarketplaceProvider>(context, listen: false).refresh();
        if (!mounted) return;

        AppNavigator.resetToHome();
        final rootCtx = AppNavigator.key.currentContext;
        if (rootCtx != null) {
          ScaffoldMessenger.of(rootCtx).showSnackBar(
            const SnackBar(
              content: Text('Akoonkaaga waa la sameeyay — waad soo gashay!'),
              backgroundColor: AppColors.green,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkBlue, size: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const ColorfulHello(fontSize: 32),
              const SizedBox(height: 10),
              const Text(
                "Buy. Sell. Anything. Anywhere.",
                style: TextStyle(color: AppColors.textGray, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 36),
              CustomTextField(
                label: "Full Name",
                hint: "Ahmed Ali",
                prefixIcon: Icons.person_outline_rounded,
                controller: _nameController,
                validator: (v) => v == null || v.isEmpty ? "Name is required" : null,
              ),

              const Text(
                "Phone Number",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF374151), letterSpacing: 0.3),
              ),
              const SizedBox(height: 10),
              IntlPhoneField(
                decoration: InputDecoration(
                  hintText: "61XXXXXXX",
                  hintStyle: const TextStyle(color: Color(0xFFADB5BD), fontWeight: FontWeight.w500),
                  filled: true,
                  fillColor: AppColors.lightGray,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.green, width: 2),
                  ),
                ),
                initialCountryCode: 'SO',
                showDropdownIcon: true,
                showCountryFlag: true,
                disableLengthCheck: true, // Allows more/less digits
                dropdownIconPosition: IconPosition.trailing,
                onChanged: (phone) {
                  _phoneNumber = phone.completeNumber;
                },
              ),
              const SizedBox(height: 10),
              CustomTextField(
                label: "Password",
                hint: "At least 6 characters",
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: _obscurePassword,
                controller: _passwordController,
                suffixIcon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                onSuffixPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                validator: (v) => v == null || v.length < 6 ? "Password must be at least 6 characters" : null,
              ),
              const SizedBox(height: 28),
              
              // Note
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.green, size: 18),
                  SizedBox(width: 10),
                  Expanded(child: Text(
                    "You are signing up as a Customer. Sellers and Delivery accounts are created by Admin.",
                    style: TextStyle(color: AppColors.darkBlue, fontSize: 12, fontWeight: FontWeight.w600, height: 1.4),
                  )),
                ]),
              ),
              const SizedBox(height: 36),
              
              // Sign Up Button
              auth.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Create My Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    ),
                    
              const SizedBox(height: 28),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?", style: TextStyle(color: AppColors.textGray, fontWeight: FontWeight.w500)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Sign In", style: TextStyle(color: AppColors.darkBlue, fontWeight: FontWeight.w800, fontSize: 15)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
