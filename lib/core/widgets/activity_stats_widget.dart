import 'package:flutter/material.dart';
import 'package:furtive/core/entities/activity_entity.dart';
import 'package:furtive/core/extensions.dart';

class ActivityStatsWidget extends StatelessWidget {
  final ActivityEntity activity;
  final Duration elapsedTime;

  const ActivityStatsWidget({
    super.key,
    required this.activity,
    required this.elapsedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: Colors.black),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                child: Text(
                  'Recording Activity',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                elapsedTime.toHHMMSS(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 145),
            child: PageView(
              children: [
                _buildStatsPage(
                  label: 'Active',
                  duration: activity.activeDuration.toHHMMSS(),
                  distance: activity.activeDistanceInKm.toStringAsFixed(2),
                  speed: activity.activeSpeedKmh.toStringAsFixed(1),
                  pace: activity.activePaceMinPerKm,
                  elevation: activity.activeElevation,
                ),
                _buildStatsPage(
                  label: 'Paused',
                  duration: activity.pausedDuration.toHHMMSS(),
                  distance: activity.pausedDistanceInKm.toStringAsFixed(2),
                  speed: activity.pausedSpeedKmh.toStringAsFixed(1),
                  pace: activity.pausedPaceMinPerKm,
                  elevation: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildStatsPage({
  required String label,
  required String duration,
  required String distance,
  required String speed,
  required String pace,
  required ({double gain, double loss})? elevation,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              duration,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$pace /km',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$distance km',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$speed km/h',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (elevation != null) ...[
              Text(
                '+${elevation.gain.toStringAsFixed(0)}m / -${elevation.loss.toStringAsFixed(0)}m',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ],
    ),
  );
}
