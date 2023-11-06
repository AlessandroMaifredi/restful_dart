import 'package:collection/collection.dart';
import 'package:restful_dart/restful_exception.dart';

/// The available roles for a player
enum PlayerRole {
  middleBlocker,
  outsideHitter,
  opposite,
  setter,
  libero,
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
  /// Throws a [RestfulException] if the role is not found
  static PlayerRole fromString(String role) {
    PlayerRole? playerRole =
        PlayerRole.values.firstWhereOrNull((element) => element.name == role);
    if (playerRole == null) {
      throw RestfulException(message: 'PlayerRole not found', code: 500);
    }
    return playerRole;
  }
}
