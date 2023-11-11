import 'package:collection/collection.dart';

/// The available roles for a player
enum PlayerRole {
  middleBlocker,
  outsideHitter,
  opposite,
  setter,
  libero,
  none,
}

/// A serializable version of the [PlayerRole] enum
extension SerialazablePlayerRole on PlayerRole {
  /// Serialization to json
  Map<String, dynamic> toJson() {
    return {
      'playerRole': name,
    };
  }

  /// Deserialization from string
  /// Returns [PlayerRole.none] if the string is not a valid role
  static PlayerRole fromString(String role) {
    PlayerRole? playerRole =
        PlayerRole.values.firstWhereOrNull((element) => element.name == role);
    if (playerRole == null) {
      return PlayerRole.none;
    }
    return playerRole;
  }
}
