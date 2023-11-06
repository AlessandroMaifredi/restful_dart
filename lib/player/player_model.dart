import 'package:collection/collection.dart';
import 'package:restful_dart/player/player_role_model.dart';

/// The player model
class Player {
  /// The age of the player
  final int age;

  /// The roles of the player
  final List<PlayerRole> playerRoles;

  /// The id of the player in the database
  final String id;

  /// The name of the player
  final String name;

  /// The family name of the player
  final String familyName;

  /// The email of the player
  final String email;

  /// Standard constructor
  Player({
    required this.id,
    required this.age,
    required this.playerRoles,
    required this.name,
    required this.familyName,
    required this.email,
  });

  /// Factory constructor for deserialization from json
  factory Player.fromJson(Map<String, dynamic> map) {
    return Player(
      id: map['_id'],
      age: map['age'],
      name: map['name'],
      familyName: map['familyName'],
      email: map['email'],
      playerRoles: map['roles']
          .map((e) => SerialazablePlayerRole.fromString(e))
          .toList(),
    );
  }

  /// Serialization to json
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'age': age,
      'playerRoles': playerRoles.map((e) => e.toJson()).toList(),
      'name': name,
      'familyName': familyName,
      'email': email,
    };
  }

  /// Serialization to string
  @override
  String toString() {
    return 'Player{age: $age, playerRoles: $playerRoles, id: $id, name: $name, familyName: $familyName, email: $email}';
  }

  /// Equality operator, uses the [ListEquality] to compare the [playerRoles]
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player &&
          runtimeType == other.runtimeType &&
          age == other.age &&
          ListEquality().equals(playerRoles, other.playerRoles) &&
          id == other.id &&
          name == other.name &&
          familyName == other.familyName &&
          email == other.email;

  /// Hashcode operator
  @override
  int get hashCode =>
      age.hashCode ^
      playerRoles.hashCode ^
      id.hashCode ^
      name.hashCode ^
      familyName.hashCode ^
      email.hashCode;
}
