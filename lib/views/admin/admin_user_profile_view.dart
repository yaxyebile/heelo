import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../core/constants/colors.dart';
import '../../models/app_user.dart';

class AdminUserProfileView extends StatefulWidget {
  final String userId;
  const AdminUserProfileView({super.key, required this.userId});

  @override
  State<AdminUserProfileView> createState() => _AdminUserProfileViewState();
}

class _AdminUserProfileViewState extends State<AdminUserProfileView> {
  AppUser? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await SupabaseService.fetchProfileById(widget.userId);
    setState(() {
      _user = u;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF97316)))
          : _user == null
              ? const Center(child: Text('User not found', style: TextStyle(color: Colors.grey)))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          child: const Icon(Icons.person, size: 50),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Magaca: ${_user!.name}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Email: ${_user!.email}', style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      Text('Phone: ${_user!.phone ?? "-"}', style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      Text('Role: ${_user!.role.name}', style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
    );
  }
}
