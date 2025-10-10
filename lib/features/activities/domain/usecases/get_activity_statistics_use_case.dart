import 'package:geolocator/geolocator.dart';
import 'package:openstreetmap/features/activities/domain/entities/activity_statistics_entity.dart';
import 'package:openstreetmap/features/map/domain/entities/activity_entity.dart';

class ActivitySegment {
  final List<ActivityPointEntity> points;
  final ActivityPointStatusEntity status;

  ActivitySegment({required this.points, required this.status});

  bool get isActive => status == ActivityPointStatusEntity.active;
  bool get isPaused => status == ActivityPointStatusEntity.paused;
}

class GetActivityStatisticsUseCase {
  GetActivityStatisticsUseCase();

  ActivityStatisticsEntity call(ActivityEntity activity) {
    final activityDuration =
        activity.stoppedAt != null
            ? activity.stoppedAt!.difference(activity.startedAt)
            : DateTime.now().difference(activity.startedAt);

    if (activity.points.isEmpty) {
      return ActivityStatisticsEntity(
        activityDuration: activityDuration,

        activeDuration: Duration.zero,
        activeDistanceInMeters: 0.0,
        activeElevationGain: 0.0,
        activeElevationLoss: 0.0,

        pausedDuration: Duration.zero,
        pausedDistanceInMeters: 0.0,
      );
    }

    final segments = _segmentPoints(activity.points);
    final activeSegments = segments.where((s) => s.isActive).toList();
    final pausedSegments = segments.where((s) => s.isPaused).toList();

    final activeDuration = _calculateSegmentsDuration(activeSegments);
    final activeDistance = _calculateSegmentsDistance(activeSegments);
    final (
      gain: activeElevationGain,
      loss: activeElevationLoss,
    ) = _calculateSegmentsElevation(activeSegments);

    final pausedDuration = _calculateSegmentsDuration(pausedSegments);
    final pausedDistance = _calculateSegmentsDistance(pausedSegments);

    return ActivityStatisticsEntity(
      activityDuration: activityDuration,

      activeDuration: activeDuration,
      activeDistanceInMeters: activeDistance,
      activeElevationGain: activeElevationGain,
      activeElevationLoss: activeElevationLoss,

      pausedDuration: pausedDuration,
      pausedDistanceInMeters: pausedDistance,
    );
  }

  List<ActivitySegment> _segmentPoints(List<ActivityPointEntity> points) {
    if (points.isEmpty) return [];

    // Ensure they are sorted by time earliest to latest
    points.sort((a, b) => a.time.compareTo(b.time));

    final segments = <ActivitySegment>[];
    var currentSegmentPoints = <ActivityPointEntity>[points.first];
    var currentStatus = points.first.status;

    for (final point in points) {
      if (point.status == currentStatus) {
        currentSegmentPoints.add(point);
      } else {
        segments.add(
          ActivitySegment(
            points: List.unmodifiable(currentSegmentPoints),
            status: currentStatus,
          ),
        );
        currentSegmentPoints = [point];
        currentStatus = point.status;
      }
    }

    segments.add(
      ActivitySegment(
        points: List.unmodifiable(currentSegmentPoints),
        status: currentStatus,
      ),
    );

    return segments;
  }

  Duration _calculateSegmentsDuration(List<ActivitySegment> segments) {
    if (segments.isEmpty) return Duration.zero;

    var totalDuration = Duration.zero;
    for (final segment in segments) {
      if (segment.points.isEmpty) continue;

      final firstPoint = segment.points.first;
      final lastPoint = segment.points.last;
      final duration = lastPoint.time.difference(firstPoint.time);
      totalDuration += duration;
    }
    return totalDuration;
  }

  double _calculateSegmentsDistance(List<ActivitySegment> segments) {
    double totalDistance = 0.0;
    for (final segment in segments) {
      final points = segment.points;
      double segmentDistance = 0.0;
      for (int i = 0; i < points.length - 1; i++) {
        segmentDistance += Geolocator.distanceBetween(
          points[i].position.latitude,
          points[i].position.longitude,
          points[i + 1].position.latitude,
          points[i + 1].position.longitude,
        );
      }
      totalDistance += segmentDistance;
    }
    return totalDistance;
  }

  ({double gain, double loss}) _calculateSegmentsElevation(
    List<ActivitySegment> segments,
  ) {
    double totalGain = 0.0;
    double totalLoss = 0.0;

    for (final segment in segments) {
      double segmentGain = 0.0;
      double segmentLoss = 0.0;
      final points = segment.points;

      for (int i = 0; i < points.length - 1; i++) {
        final currentPoint = points[i];
        final nextPoint = points[i + 1];
        final elevationGain =
            nextPoint.position.elevation - currentPoint.position.elevation;
        if (elevationGain > 0) segmentGain += elevationGain;
        if (elevationGain < 0) segmentLoss += elevationGain;
      }
      totalGain += segmentGain;
      totalLoss += segmentLoss;
    }
    return (gain: totalGain, loss: totalLoss);
  }
}
