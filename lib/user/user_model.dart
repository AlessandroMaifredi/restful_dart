import 'package:collection/collection.dart';
import 'package:restful_dart/user/user_role_model.dart';

class User {
  String id;
  String name;
  String familyName;
  String email;
  List<UserRole> roles;

  User(
      {required this.id,
      required this.name,
      required this.familyName,
      required this.email,
      required this.roles});

  @override
  String toString() {
    return 'User{name: $name, familyName: $familyName, email: $email, roles: $roles}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          familyName == other.familyName &&
          email == other.email &&
          ListEquality().equals(roles, other.roles);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      familyName.hashCode ^
      email.hashCode ^
      roles.hashCode;

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'],
      name: map['name'],
      familyName: map['familyName'],
      email: map['email'],
      roles: map['roles'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'familyName': familyName,
      'email': email,
      'roles': roles,
    };
  }
}
