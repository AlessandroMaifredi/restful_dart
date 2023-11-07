import 'dart:io' show InternetAddress, Platform;

import 'package:mongo_dart/mongo_dart.dart';

/// The host for the database connection
/// Use the environment variable MONGO_DART_DRIVER_HOST to override
/// Defaults to 127.0.0.1
final String host = Platform.environment['MONGO_DART_DRIVER_HOST'] ??
    InternetAddress.loopbackIPv4.toString();

/// The port for the database connection
/// Use the environment variable MONGO_DART_DRIVER_PORT to override
/// Defaults to 27017
final String port = Platform.environment['MONGO_DART_DRIVER_PORT'] ?? '27017';

/// A singleton class to manage the database connection
class DbDriver {
  /// The database connection
  final Db _mongoDb = Db('mongodb://$host:$port/restfuldart');

  /// The default limit for queries
  /// Use the environment variable API_DEFAULT_QUERIES_LIMIT to override
  /// Defaults to 10
  static final int defaultQueryLimit = int.tryParse(
          Platform.environment['API_DEFAULT_QUERIES_LIMIT'].toString()) ??
      10;

  /// The default page for queries
  /// Use the environment variable API_DEFAULT_QUERIES_PAGE to override
  /// Defaults to 1
  static int defaultQueryPage = int.tryParse(
          Platform.environment['API_DEFAULT_QUERIES_PAGE'].toString()) ??
      1;

  /// The singleton instance of this class
  static DbDriver get instance => DbDriver._();

  /// A helper factory constructor
  Db get mongoDb => _mongoDb;

  /// Private constructor
  DbDriver._();
}
