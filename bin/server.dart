import 'dart:io';

import 'package:dart_ping/dart_ping.dart';
import 'package:restful_dart/db_driver/db_driver.dart';
import 'package:restful_dart/root/root_api.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

/// The main entry point for the application
void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.loopbackIPv4;
  final serverPort = int.parse(Platform.environment['PORT'] ?? '8080');
  final app = RootApi().router;
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(app);

  final server = await serve(handler, ip, serverPort);
  print('Server listening on $ip on port ${server.port}');
  final ping = Ping('$host:$port', count: 1000, interval: 2);
  ping.stream.listen((event) {
    print("New ping: $event");
  });
  /*await DbDriver.instance.mongoDb.open();

  assert(DbDriver.instance.mongoDb.state == State.open);
  print("Using DB: ${DbDriver.instance.mongoDb.databaseName}");

  app.mount(PlayerApi.uriPath, PlayerApi().router);*/
}
