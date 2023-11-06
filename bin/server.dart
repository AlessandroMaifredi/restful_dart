import 'dart:io';

import 'package:restful_dart/db_driver/db_driver.dart';
import 'package:restful_dart/player/player_api.dart';
import 'package:restful_dart/root/root_api.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

/// The main entry point for the application
void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  await DbDriver.instance.mongoDb.open();
  DbDriver.instance.mongoDb.listDatabases().then((value) => print(value));
  final app = RootApi().router;
  app.mount(PlayerApi.uriPath, PlayerApi().router);
  final handler =
      Pipeline().addMiddleware(logRequests()).addHandler(RootApi().router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
