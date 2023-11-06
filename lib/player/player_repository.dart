import 'package:mongo_dart/mongo_dart.dart';
import 'package:restful_dart/db_driver/db_driver.dart';
import 'package:restful_dart/player/player_model.dart';
import 'package:restful_dart/restful_exception.dart';

/// The repository for the player resource
class PlayerRepository {
  /// The collection for the player resource in the database
  final DbCollection _playerCollection =
      DbDriver.instance.mongoDb.collection('players');

  /// Private constructor
  PlayerRepository._() {
    Future.wait([_init()]);
  }

  /// Initialize the database ensuring the index by familyName and name for the player resource
  Future<void> _init() async {
    await DbDriver.instance.mongoDb.ensureIndex('players',
        name: 'meta', keys: {'_id': 1, 'familyName': 1, 'name': 1});
  }

  /// The singleton instance of this repository
  static final PlayerRepository instance = PlayerRepository._();

  /// A helper factory constructor
  factory PlayerRepository() => instance;

  /// Get all players
  ///
  /// Supports pagination
  ///
  /// See GET /v1/players?limit=<limit>&page=<page> for more information
  ///
  /// Returns a list of players
  ///
  /// The results are sorted by familyName
  /// Throws a [RestfulException] if the operation fails for any reason
  Future<List<Player>> getAllPlayers({int? limit, int? page}) {
    limit ??= DbDriver.defaultQueryLimit;
    page ??= DbDriver.defaultQueryPage;
    return _playerCollection
        .find(where.sortBy("familyName").limit(limit).skip((page - 1) * limit))
        .map((event) => Player.fromJson(event))
        .toList()
        .catchError(
            (e) => throw RestfulException(code: 500, message: e.toString()));
  }

  /// Get a player by id
  ///
  /// See GET /v1/players/<id> for more information
  ///
  /// Returns the player
  ///
  /// Throws a [RestfulException] with code 404 if the player is not found
  /// Throws a [RestfulException] if the operation fails for any other reason
  Future<Player> getPlayerById(String id) =>
      _playerCollection.findOne(where.eq('_id', id)).then((value) {
        if (value == null) {
          throw RestfulException(code: 404, message: 'Player not found');
        }
        return Player.fromJson(value);
      }).catchError(
          (e) => throw RestfulException(code: 500, message: e.toString()));

  /// Get all players that have at least the given role
  ///
  /// See GET /v1/players/roles/<role> for more information
  ///
  /// Supports pagination
  ///
  /// Returns a list of players
  ///
  /// Throws a [RestfulException] if the operation fails for any reason
  Future<List<Player>> getPlayersByRole(String role, {int? limit, int? page}) {
    limit ??= DbDriver.defaultQueryLimit;
    page ??= DbDriver.defaultQueryPage;
    return _playerCollection
        .find(where
            .oneFrom('playerRoles', [role])
            .limit(limit)
            .skip((page - 1) * limit))
        .map((event) => Player.fromJson(event))
        .toList()
        .catchError(
            (e) => throw RestfulException(code: 500, message: e.toString()));
  }

  /// Create a new player
  ///
  /// See POST /v1/players for more information
  ///
  /// Returns the created player
  ///
  /// Throws a [RestfulException] with code 400 if the player already exists
  /// Throws a [RestfulException] if the operation fails for any other reason
  Future<Player> createPlayer({required Player player}) {
    try {
      getPlayerById(player.id);
    } on RestfulException catch (e) {
      if (e.code == 404) {
        return _playerCollection
            .insert(player.toJson())
            .then((value) => Player.fromJson(value))
            .catchError((e) =>
                throw RestfulException(code: 500, message: e.toString()));
      }
    }
    throw RestfulException(code: 400, message: 'Player already exists');
  }

  /// Update a player
  ///
  /// See PUT /v1/players for more information
  ///
  /// If the player is not changed, the old player is returned
  ///
  /// Returns the updated player
  ///
  /// Throws a [RestfulException] with code 404 if the player is not found
  /// Throws a [RestfulException] if the operation fails for any other reason
  Future<Player> updatePlayer({required Player player}) async {
    try {
      Player old = await getPlayerById(player.id);
      if (old == player) {
        return old;
      }
    } catch (_) {
      rethrow;
    }
    return _playerCollection
        .replaceOne(where.eq('_id', player.id), player.toJson())
        .then((value) {
      if (value.isSuccess) {
        return Player.fromJson(value.document!.cast<String, dynamic>());
      }
      throw RestfulException(code: 500, message: 'Player not updated');
    }).catchError(
            (e) => throw RestfulException(code: 500, message: e.toString()));
  }

  /// Delete a player
  ///
  /// See DELETE /v1/players for more information
  ///
  /// Returns the deleted player
  ///
  /// Throws a [RestfulException] with code 404 if the player is not found
  /// Throws a [RestfulException] if the operation fails for any other reason
  Future<Player> deletePlayer({required String id}) async {
    try {
      await getPlayerById(id);
    } catch (_) {
      rethrow;
    }

    return _playerCollection.remove(where.eq('_id', id)).then((value) {
      return Player.fromJson(value);
    }).catchError(
        (e) => throw RestfulException(code: 500, message: e.toString()));
  }
}
