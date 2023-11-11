import 'package:restful_dart/player/player_role_model.dart';

/// The player model
class Player {
  /// The age of the player
  final int age;

  /// The role of the player
  final PlayerRole playerRole;

  /// The id of the player in the database
  final int id;

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
    required this.playerRole,
    required this.name,
    required this.familyName,
    required this.email,
  });

  /// Factory constructor for deserialization from json
  factory Player.fromJson(Map<String, dynamic> map) {
    return Player(
      id: (map['id'] ?? 0),
      age: int.tryParse(map['age'].toString()) ?? 0,
      name: map['name'],
      familyName: map['familyName'],
      email: map['email'],
      playerRole: SerialazablePlayerRole.fromString(map['playerRole']),
    );
  }

  /// Serialization to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'age': age,
      'playerRole': playerRole.name,
      'name': name,
      'familyName': familyName,
      'email': email,
    };
  }

  /// Serialization to string
  @override
  String toString() {
    return 'Player{age: $age, playerRole: $playerRole, id: $id, name: $name, familyName: $familyName, email: $email}';
  }

  /// Equality operator
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player &&
          runtimeType == other.runtimeType &&
          age == other.age &&
          playerRole == other.playerRole &&
          id == other.id &&
          name == other.name &&
          familyName == other.familyName &&
          email == other.email;

  /// Hashcode operator
  @override
  int get hashCode =>
      age.hashCode ^
      playerRole.hashCode ^
      id.hashCode ^
      name.hashCode ^
      familyName.hashCode ^
      email.hashCode;
}
