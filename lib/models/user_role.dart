import 'package:hive/hive.dart';

part 'user_role.g.dart';

@HiveType(typeId: 0)
enum UserRole {
  @HiveField(0)
  user,
  @HiveField(1)
  seller,
  @HiveField(2)
  admin,
  @HiveField(3)
  delivery,
}
