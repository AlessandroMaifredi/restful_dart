import 'package:mongo_dart/mongo_dart.dart';
import 'package:restful_dart/player/player_model.dart';
import 'package:restful_dart/player/player_role_model.dart';
import 'package:restful_dart/restful_exception.dart';

class PlayerRepository {
  final DbCollection playerCollection;

  PlayerRepository({required Db mongoDb})
      : playerCollection = mongoDb.collection('players');

  Future<List<Player>> getAllPlayers() =>
      playerCollection.find().map((event) => Player.fromMap(event)).toList();

  Future<Player> getPlayerById(String id) => playerCollection
          .findOne(where.eq('_id', id).sortBy("familyName"))
          .then((value) {
        if (value == null) {
          throw RestfulException(code: 404, message: 'Player not found');
        }
        return Player.fromMap(value);
      }).catchError(
              (e) => throw RestfulException(code: 500, message: e.toString()));

  Future<List<Player>> getPlayersById(List<String> ids) => playerCollection
      .find(where.oneFrom('_id', ids).sortBy("familyName"))
      .map((event) => Player.fromMap(event))
      .toList()
      .catchError(
          (e) => throw RestfulException(code: 500, message: e.toString()));

  Future<List<Player>> getPlayersByRoles(
          List<PlayerRole> roles) =>
      playerCollection
          .find(where.oneFrom('playerRoles', roles).sortBy("familyName"))
          .map((event) => Player.fromMap(event))
          .toList()
          .catchError(
              (e) => throw RestfulException(code: 500, message: e.toString()));

  Future<bool> createPlayer({required Player player}) {
    return playerCollection
        .insert(player.toMap())
        .then((value) => true)
        .catchError(
            (e) => throw RestfulException(code: 500, message: e.toString()));
  }

  Future<bool> updatePlayer({required Player player}) {
    return playerCollection
        .replaceOne(where.eq('_id', player.id), player.toMap())
        .then((value) => true)
        .catchError(
            (e) => throw RestfulException(code: 500, message: e.toString()));
  }

  Future<bool> deletePlayer({required String id}) {
    return playerCollection
        .remove(where.eq('_id', id))
        .then((value) => true)
        .catchError(
            (e) => throw RestfulException(code: 500, message: e.toString()));
  }
}
