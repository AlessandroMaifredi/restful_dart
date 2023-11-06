import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

/// The root api for the application
class RootApi {
  /// The root path for this api
  Router get router {
    final router = Router();

    /// GET /
    ///
    /// Returns the swagger documentation
    router.get(
        '/',
        (Request request) => Response.ok(
            'https://app.swaggerhub.com/apis-docs/AMAIFREDI/RestfulDart/0.0.1-oas3.1',
            headers: {'Content-Type': 'text/plain'}));
    return router;
  }
}
