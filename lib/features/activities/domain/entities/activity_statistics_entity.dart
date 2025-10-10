import 'package:dart_mappable/dart_mappable.dart';

part 'activity_statistics_entity.mapper.dart';

@MappableClass()
class ActivityStatisticsEntity with ActivityStatisticsEntityMappable {
  final Duration activityDuration;

  final Duration activeDuration;
  final double activeDistanceInMeters;
  final double activeElevationGain;
  final double activeElevationLoss;

  final Duration pausedDuration;
  final double pausedDistanceInMeters;

  ActivityStatisticsEntity({
    required this.activityDuration,

    required this.activeDuration,
    required this.activeDistanceInMeters,
    required this.activeElevationGain,
    required this.activeElevationLoss,

    required this.pausedDuration,
    required this.pausedDistanceInMeters,
  });

  get activeDistanceInKm => activeDistanceInMeters / 1000;

  get pausedDistanceInKm => pausedDistanceInMeters / 1000;

  get activeAverageSpeedMps =>
      activeDuration.inSeconds > 0
          ? (activeDistanceInMeters / activeDuration.inSeconds)
          : 0.0;

  get pausedAverageSpeedMps =>
      pausedDuration.inSeconds > 0
          ? (pausedDistanceInMeters / pausedDuration.inSeconds)
          : 0.0;

  get activeAverageSpeedKmh => activeAverageSpeedMps * 3.6;

  get pausedAverageSpeedKmh => pausedAverageSpeedMps * 3.6;
}
