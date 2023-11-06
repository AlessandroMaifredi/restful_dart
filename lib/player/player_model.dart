import 'package:restful_dart/player/player_role_model.dart';
import 'package:restful_dart/user/user_model.dart';

class Player extends User {
  int age;
  List<PlayerRole> playerRoles;

  Player(
      {required super.id,
      required this.age,
      required this.playerRoles,
      required super.name,
      required super.familyName,
      required super.email,
      required super.roles});

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['_id'],
      age: map['age'],
      playerRoles: map['playerRoles'],
      name: map['name'],
      familyName: map['familyName'],
      email: map['email'],
      roles: map['roles'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'age': age,
      'playerRoles': playerRoles,
      'name': name,
      'familyName': familyName,
      'email': email,
      'roles': roles,
    };
  }
}
