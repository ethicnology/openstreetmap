import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openstreetmap/features/activities/domain/usecases/get_activity_statistics_use_case.dart';
import 'package:openstreetmap/features/activities/presentation/bloc/activities_bloc.dart';
import 'package:openstreetmap/features/activities/presentation/bloc/activities_event.dart';
import 'package:openstreetmap/features/activities/presentation/bloc/activities_state.dart';
import 'package:openstreetmap/features/activities/presentation/pages/activity_detail_page.dart';

class ActivitiesListPage extends StatefulWidget {
  const ActivitiesListPage({super.key});

  @override
  State<ActivitiesListPage> createState() => _ActivitiesListPageState();
}

class _ActivitiesListPageState extends State<ActivitiesListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ActivitiesBloc>().add(const FetchActivities());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivitiesBloc, ActivitiesState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage!.message,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Activities'),
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<ActivitiesBloc, ActivitiesState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.activities.isEmpty) {
              return const Center(
                child: Text(
                  'No activities found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              itemCount: state.activities.length,
              itemBuilder: (context, index) {
                final activity = state.activities[index];
                return _buildActivityCard(activity);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildActivityCard(activity) {
    final statistics = GetActivityStatisticsUseCase()(activity);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[900],
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          activity.startedAt.toLocal().toString().substring(0, 19),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatChip(_formatDuration(statistics.activeDuration)),
                const SizedBox(width: 8),
                _buildStatChip(
                  '${statistics.activeDistanceInKm.toStringAsFixed(1)} km',
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  '${statistics.activeAverageSpeedKmh.toStringAsFixed(1)} km/h',
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[400],
          size: 16,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActivityDetailPage(activity: activity),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }
}
