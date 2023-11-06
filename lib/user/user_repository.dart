import 'package:mongo_dart/mongo_dart.dart';
import 'package:restful_dart/player/player_repository.dart';
import 'package:restful_dart/restful_exception.dart';
import 'package:restful_dart/user/user_role_model.dart';

import 'user_model.dart';

class UserRepository {
  final DbCollection _userCollection;
  final Db _mongoDb;

  UserRepository({required Db mongoDb})
      : _mongoDb = mongoDb,
        _userCollection = mongoDb.collection('users');

  Future<List<User>> getAllUsers() =>
      _userCollection.find().map((event) => User.fromMap(event)).toList();

  Future<User> getUserById(String id) => _userCollection
          .findOne(where.eq('_id', id).sortBy("familyName"))
          .then((value) {
        if (value == null) {
          throw RestfulException(code: 404, message: 'User not found');
        }
        return User.fromMap(value);
      }).catchError(
              (e) => throw RestfulException(code: 500, message: e.toString()));

  Future<List<User>> getUsersById(List<String> ids) => _userCollection
      .find(where.oneFrom('_id', ids).sortBy("familyName"))
      .map((event) => User.fromMap(event))
      .toList()
      .catchError(
          (e) => throw RestfulException(code: 500, message: e.toString()));

  Future<List<User>> getUsersByRoles(List<UserRole> roles) => _userCollection
      .find(where.oneFrom('UserRoles', roles).sortBy("familyName"))
      .map((event) => User.fromMap(event))
      .toList()
      .catchError(
          (e) => throw RestfulException(code: 500, message: e.toString()));

  Future<bool> createUser({required User user}) {
    return _userCollection
        .insert(user.toMap())
        .then((value) => true)
        .catchError(
            (e) => throw RestfulException(code: 500, message: e.toString()));
  }

  Future<bool> updateUser({required User user}) async {
    bool canContinue = false;
    if (!user.roles.contains(UserRole.player)) {
      PlayerRepository playerRepository = PlayerRepository(mongoDb: _mongoDb);
      canContinue = await playerRepository.deletePlayer(id: user.id);
    } else {
      canContinue = true;
    }
    if (!canContinue) {
      throw RestfulException(
          code: 500,
          message: 'Error updating user: error removing player object.');
    }
    return _userCollection
        .replaceOne(where.eq('_id', user.id), user.toMap())
        .then((value) => true)
        .catchError(
            (e) => throw RestfulException(code: 500, message: e.toString()));
  }

  Future<bool> deleteUser({required User user}) async {
    bool canContinue = false;

    if (user.roles.contains(UserRole.player)) {
      PlayerRepository playerRepository = PlayerRepository(mongoDb: _mongoDb);
      canContinue = await playerRepository.deletePlayer(id: user.id);
    } else {
      canContinue = true;
    }
    if (!canContinue) {
      throw RestfulException(
          code: 500,
          message: 'Error updating user: error removing player object.');
    }
    return _userCollection
        .replaceOne(where.eq('_id', user.id), user.toMap())
        .then((value) => true)
        .catchError(
            (e) => throw RestfulException(code: 500, message: e.toString()));
  }
}
