import 'package:mongo_dart/mongo_dart.dart';
import 'package:restful_dart/player/player_repository.dart';

class PlayerApi {
  late PlayerRepository _playerRepository;

  PlayerApi(Db mongoDb) {
    _playerRepository = PlayerRepository(mongoDb: mongoDb);
  }
}
