import 'dart:io';

import 'package:mysql1/mysql1.dart';

/// A singleton class to manage the database connection
class DbDriver {
  /// The database connection settings
  late ConnectionSettings _connectionSettings;

  MySqlConnection? _connection;

  bool get isConnected => _connection != null;

  MySqlConnection get connection {
    if (isConnected == false) {
      throw Exception(
          "Database connection is not initialized. Did you forget to call DbDriver.instance.ensureIntialized()?");
    }
    return _connection!;
  }

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

  /// Private constructor
  DbDriver._() {
    String mySqlUser = Platform.environment['MYSQL_USER'] ?? "";
    String mySqlPassword = Platform.environment['MYSQL_PASSWORD'] ?? "";

    if (Platform.environment['MYSQL_USER_FILE'] != null) {
      File(Platform.environment['MYSQL_USER_FILE']!)
          .readAsString()
          .then((value) => mySqlUser = value);
    }
    if (Platform.environment['MYSQL_PASSWORD_FILE'] != null) {
      File(Platform.environment['MYSQL_PASSWORD_FILE']!)
          .readAsString()
          .then((value) => mySqlPassword = value);
    }
    _connectionSettings = ConnectionSettings(
        host: Platform.environment['MYSQL_HOST'] ?? 'localhost',
        port:
            int.tryParse(Platform.environment['MYSQL_PORT'].toString()) ?? 3306,
        user: mySqlUser,
        password: mySqlPassword,
        db: 'restfuldart');
  }

  Future<MySqlConnection> _init() async {
    _connection = await MySqlConnection.connect(_connectionSettings);
    return _connection!;
  }

  /// Ensures the database is initialized
  Future<bool> ensureIntialized() async {
    await _init();
    return true;
  }

  Future<void> setUpDB() async {
    await connection.query("CREATE TABLE IF NOT EXISTS players ("
        "id INT NOT NULL AUTO_INCREMENT,"
        "name VARCHAR(255) NOT NULL,"
        "age INT NOT NULL,"
        "familyName VARCHAR(255) NOT NULL,"
        "email VARCHAR(255) NOT NULL,"
        "playerRole VARCHAR(255) NOT NULL,"
        "created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,"
        "updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,"
        "PRIMARY KEY (id)"
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;");
  }
}
