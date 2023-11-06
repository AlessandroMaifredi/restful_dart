import 'dart:convert';

import 'package:restful_dart/player/player_model.dart';
import 'package:restful_dart/player/player_repository.dart';
import 'package:restful_dart/player/player_role_model.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../restful_exception.dart';

/// The v1 api for the player resource
///
/// Supports the following requests:
///
/// GET /v1/players
///
/// GET /v1/players/<id>
///
/// GET /v1/players/roles/<role>
///
/// GET /v1/players/roles
///
/// POST /v1/players
///
/// PUT /v1/players/<id>
///
/// DELETE /v1/players/<id>
class PlayerApi {
  /// The versioned path to this api
  /// /v1/players
  static String uriPath = '/v1/players';

  /// The repository for this api
  final PlayerRepository _playerRepository = PlayerRepository();

  /// Private constructor
  PlayerApi._();

  /// The singleton instance of this api
  static final PlayerApi instance = PlayerApi._();

  /// A helper factory constructor
  factory PlayerApi() => instance;

  /// The router for this api.
  ///
  /// Supports the following requests:
  ///
  /// GET /v1/players
  ///
  /// GET /v1/players/<id>
  ///
  /// GET /v1/players/roles/<role>
  ///
  /// GET /v1/players/roles
  ///
  /// POST /v1/players
  ///
  /// PUT /v1/players/<id>
  ///
  /// DELETE /v1/players/<id>
  Router get router {
    final router = Router();

    /// GET /v1/players
    ///
    /// Returns a list of all players
    ///
    /// Supports the following query parameters:
    /// - limit: The maximum number of players to return
    /// - page: The page of players to return
    ///
    /// Example:
    ///
    /// GET /v1/players?limit=10&page=1
    ///
    /// Returns the first 10 players
    router.get('/', (Request request) async {
      return Response.ok(
          jsonEncode(await _playerRepository.getAllPlayers(
              limit: int.tryParse("${request.params['limit']}"),
              page: int.tryParse("${request.params['page']}"))),
          headers: {'Content-Type': 'application/json'});
    });

    /// GET /v1/players/<id>
    ///
    /// Returns a single player by id
    ///
    /// Path parameters:
    /// - id: The id of the player to return
    ///
    /// Example:
    ///
    /// GET /v1/players/1
    ///
    /// Returns the player with id 1
    router.get('/<id>', (Request request, String id) async {
      try {
        final res = jsonEncode(await _playerRepository.getPlayerById(id));
        return Response.ok(res, headers: {'Content-Type': 'application/json'});
      } on RestfulException catch (e) {
        if (e.code == 404) {
          return Response.notFound(e.message);
        }
        if (e.code == 400) {
          return Response.badRequest(body: e.message);
        }
        return Response(e.code, body: e.message);
      } catch (e) {
        return Response.internalServerError(body: e.toString());
      }
    });

    /// GET /v1/players/roles/<role>
    ///
    /// Returns a list of players by role
    ///
    /// Path parameters:
    /// - role: The role of the players to return
    ///
    /// Supports the following query parameters:
    ///
    /// - limit: The maximum number of players to return
    /// - page: The page of players to return
    ///
    /// Example:
    ///
    /// GET /v1/players/roles/setter?limit=10&page=1
    router.get('/roles/<role>', (Request request, String role) async {
      if (PlayerRole.values.map((e) => e.name).contains(role)) {
        Response.badRequest(
            body:
                'Role does not exists, please use one of: ${PlayerRole.values.map((e) => e.name)}');
      }
      final res = jsonEncode(await _playerRepository.getPlayersByRole(role,
          limit: int.tryParse("${request.params['limit']}"),
          page: int.tryParse("${request.params['page']}")));
      return Response.ok(res, headers: {'Content-Type': 'application/json'});
    });

    router.get('/roles', (Request request) async {
      return Response.ok(
          jsonEncode(PlayerRole.values.map((e) => e.name).toList()),
          headers: {'Content-Type': 'application/json'});
    });

    /// POST /v1/players
    ///
    /// Creates a new player if the id does not exists
    ///
    /// Request body:
    ///
    /// {
    ///  "id": "1",
    ///  "name": "John",
    ///  "familyName": "Doe",
    ///  "playerRoles": ["middleBlocker", "setter"],
    ///  "age": 25,
    ///  "email": "john.doe@domain.com"
    ///  }
    ///
    /// Returns the created player
    ///
    /// The method is NOT idempotent, meaning that if the player already exists, it will return a 400 Bad Request
    router.post('/', (Request request) async {
      try {
        final body = await request.readAsString();
        final Player player = Player.fromJson(jsonDecode(body));
        final res =
            jsonEncode(await _playerRepository.createPlayer(player: player));
        return Response.ok(res, headers: {'Content-Type': 'application/json'});
      } on RestfulException catch (e) {
        if (e.code == 400) {
          return Response.badRequest(body: e.message);
        }
        return Response(e.code, body: e.message);
      } catch (e) {
        return Response.internalServerError(body: e.toString());
      }
    });

    /// PUT /v1/players/<id>
    ///
    /// Updates a player
    ///
    /// Path parameters:
    /// - id: The id of the player to update
    ///
    /// Request body:
    ///
    /// {
    /// "id": "1",
    /// "name": "John",
    /// "familyName": "Doe",
    /// "playerRoles": ["middleBlocker", "setter"],
    /// "age": 25,
    ///  "email": "john.doe@domain.com"
    /// }
    ///
    /// Returns the updated player
    ///
    /// If the id in the body and the path are not the same, it will return a 400 Bad Request
    ///
    /// If the player does not exists, it will return a 404 Not Found
    ///
    /// If the player in the request body is the same as the one in the db, it will return the player without calling the db
    router.put('/<id>', (Request request, String id) async {
      try {
        final body = await request.readAsString();
        final Player player = Player.fromJson(jsonDecode(body));
        if (player.id != id) {
          return Response.badRequest(
              body: 'Id in body and path must be the same');
        }
        final res =
            jsonEncode(await _playerRepository.updatePlayer(player: player));
        return Response.ok(res, headers: {'Content-Type': 'application/json'});
      } on RestfulException catch (e) {
        if (e.code == 404) {
          return Response.notFound(e.message);
        }
        return Response(e.code, body: e.message);
      } catch (e) {
        return Response.internalServerError(body: e.toString());
      }
    });

    /// DELETE /v1/players/<id>
    ///
    /// Deletes a player
    ///
    /// Path parameters:
    /// - id: The id of the player to delete
    ///
    /// Returns the deleted player
    ///
    /// The method is idempotent, meaning that if the player does not exists, it will return a 200 OK
    router.delete('/<id>', (Request request, String id) async {
      try {
        if (id.isEmpty) {
          return Response.badRequest(body: 'Id must not be empty');
        }
        final res = jsonEncode(await _playerRepository.deletePlayer(id: id));
        return Response.ok(res, headers: {'Content-Type': 'application/json'});
      } on RestfulException catch (e) {
        if (e.code == 404) {
          return Response.ok(null);
        }
        return Response(e.code, body: e.message);
      } catch (e) {
        return Response.internalServerError(body: e.toString());
      }
    });

    return router;
  }
}
