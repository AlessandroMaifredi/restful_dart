import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:restful_dart/db_driver/db_driver.dart';
import 'package:restful_dart/player/player_api.dart';
import 'package:restful_dart/root/root_api.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

/// The main entry point for the application
void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final app = RootApi().router;
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(app);

  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');

  await DbDriver.instance.mongoDb.open();

  assert(DbDriver.instance.mongoDb.state == State.open);
  print("Using DB: ${DbDriver.instance.mongoDb.databaseName}");

  app.mount(PlayerApi.uriPath, PlayerApi().router);
}
