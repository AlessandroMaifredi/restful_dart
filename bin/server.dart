import 'dart:io';

import 'package:restful_dart/db_driver/db_driver.dart';
import 'package:restful_dart/player/player_api.dart';
import 'package:restful_dart/root/root_api.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

/// The main entry point for the application
void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.tryParse("0.0.0.0") ?? InternetAddress.anyIPv4;
  final serverPort = int.parse(Platform.environment['PORT'] ?? '8080');
  final app = RootApi().router;
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(app);

  final server = await serve(handler, ip, serverPort);
  print('Server listening on $ip on port ${server.port}');

  DbDriver dbDriver = DbDriver.instance;

  await dbDriver.ensureIntialized();

  print("DB isConnected: [${DbDriver.instance.isConnected}], "
      "Using DB: restfuldart");

  await dbDriver.setUpDB();

  app.mount(PlayerApi.uriPath, PlayerApi().router);
}
