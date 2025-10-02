import 'package:openstreetmap/core/errors.dart';

class ActivityNotStartedError extends AppError {
  ActivityNotStartedError() : super('Activity not started');
}

class ActivityFirstPointMissingError extends AppError {
  ActivityFirstPointMissingError() : super('Activity first point missing');
}
