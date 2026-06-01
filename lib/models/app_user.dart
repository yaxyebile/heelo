import 'package:hive/hive.dart';
import 'user_role.dart';

part 'app_user.g.dart';

@HiveType(typeId: 1)
class AppUser extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String password;
  @HiveField(4)
  final UserRole role;
  @HiveField(5)
  final String? storeId; // For staff role
  @HiveField(6)
  final String? phone; // Added phone field

  final bool isBanned;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.storeId,
    this.phone,
    this.isBanned = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'role': role.name,
        'store_id': storeId,
        'phone': phone,
        'is_banned': isBanned,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        password: json['password'] as String,
        role: UserRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => UserRole.user,
        ),
        storeId: json['store_id'] as String?,
        phone: json['phone'] as String?,
        isBanned: json['is_banned'] as bool? ?? false,
      );
}
