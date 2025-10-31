import 'package:flutter/material.dart';

export 'extensions.dart';
export 'errors.dart';

Size screen = Size(0, 0);

class Global {
  static const maxZoom = 18.0;
  static const defaultZoom = 12.0;

  static final padding = screen.width * 0.05;
  static final spacing = screen.width * 0.05;
}
