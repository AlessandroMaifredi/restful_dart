import 'package:restful_dart/db_driver/db_driver.dart';
import 'package:restful_dart/player/player_model.dart';
import 'package:restful_dart/restful_exception.dart';

/// The repository for the player resource
class PlayerRepository {
  /// The collection for the player resource in the database
  final DbDriver dbDriver = DbDriver.instance;

  /// Private constructor
  PlayerRepository._() {
    dbDriver.ensureIntialized();
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
    int offset = (page - 1) * limit;
    return dbDriver.connection.query(
        'SELECT * FROM players'
        ' ORDER BY familyName,id'
        ' LIMIT ? OFFSET ?',
        [limit, offset]).then((results) {
      List<Player> players = [];
      for (var row in results) {
        players.add(Player.fromJson(row.fields));
      }
      return players;
    });
  }

  /// Get a player by id
  ///
  /// See GET /v1/players/<id> for more information
  ///
  /// Returns the player
  ///
  /// Throws a [RestfulException] with code 404 if the player is not found
  /// Throws a [RestfulException] if the operation fails for any other reason
  Future<Player> getPlayerById(int id) {
    return dbDriver.connection.query(
        'SELECT * FROM players'
        ' WHERE id = ?',
        [id]).then((results) {
      if (results.isEmpty) {
        throw RestfulException(code: 404, message: 'Player not found');
      }
      return Player.fromJson(results.first.fields);
    });
  }

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
    return dbDriver.connection.query(
        'SELECT * FROM players'
        ' WHERE playerRole = ?'
        ' ORDER BY familyName,id'
        ' LIMIT ? OFFSET ?',
        [role, limit, (page - 1) * limit]).then((results) {
      List<Player> players = [];
      for (var row in results) {
        players.add(Player.fromJson(row.fields));
      }
      return players;
    });
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
    return dbDriver.connection.query(
        'INSERT INTO players (name, age, familyName, email, playerRole)'
        ' VALUES ( ?, ?, ?, ?, ?)',
        [
          player.name,
          player.age,
          player.familyName,
          player.email,
          player.playerRole.name,
        ]).then((results) {
      return getPlayerById(results.insertId ?? results.first.fields['id'] ?? 0);
    }, onError: (e) {
      throw RestfulException(code: 400, message: e.toString());
    });
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
    return dbDriver.connection
        .query(
            'UPDATE players'
            ' SET name = ?, age = ?, familyName = ?, email = ?, playerRole = ?'
            ' WHERE id = ?',
            [
              player.name,
              player.age,
              player.familyName,
              player.email,
              player.playerRole.name,
              player.id
            ])
        .then((_) => player)
        .catchError((e) {
          throw RestfulException(code: 500, message: e.toString());
        });
  }

  /// Delete a player
  ///
  /// See DELETE /v1/players for more information
  ///
  /// Returns the deleted player
  ///
  /// Throws a [RestfulException] with code 404 if the player is not found
  /// Throws a [RestfulException] if the operation fails for any other reason
  Future<Player> deletePlayer({required int id}) async {
    try {
      Player pl = await getPlayerById(id);
      return dbDriver.connection
          .query(
              'DELETE FROM players'
              ' WHERE id = ?',
              [id])
          .then((value) => pl)
          .catchError((e) {
            throw RestfulException(code: 500, message: e.toString());
          });
    } catch (_) {
      rethrow;
    }
  }
}
