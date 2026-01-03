// Conditional export to allow compilation on web/desktop without pulling in dart:io on web.
export 'io_io.dart' if (dart.library.html) 'io_stub.dart';
