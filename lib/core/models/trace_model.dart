import 'package:furtive/core/entities/trace_entity.dart';
import 'package:xml/xml.dart';

class TraceModel {
  final String name;
  final String description;
  final String url;
  final List<TracePointModel> points;

  TraceModel({
    required this.name,
    required this.description,
    required this.url,
    required this.points,
  });

  static TraceEntity toEntity(TraceModel model) {
    return TraceEntity(
      name: model.name,
      description: model.description,
      url: model.url,
      points: model.points.map(TracePointModel.toEntity).toList(),
    );
  }

  static TraceModel fromEntity(TraceEntity entity) {
    return TraceModel(
      name: entity.name,
      description: entity.description,
      url: entity.url,
      points: entity.points.map(TracePointModel.fromEntity).toList(),
    );
  }

  static TraceModel fromGpx(XmlElement track) {
    final name = track.findElements('name').firstOrNull?.innerText ?? 'Unknown';
    final description = track.findElements('desc').firstOrNull?.innerText ?? '';
    final url = track.findElements('url').firstOrNull?.innerText ?? '';
    final trackPoints = track.findAllElements('trkpt');
    final points =
        trackPoints.map((point) {
          final lat = double.parse(point.getAttribute('lat') ?? '0');
          final lon = double.parse(point.getAttribute('lon') ?? '0');
          final timeStr = point.findElements('time').firstOrNull?.innerText;
          final time = timeStr != null ? DateTime.parse(timeStr) : null;
          final eleStr = point.findElements('ele').firstOrNull?.innerText;
          final elevation = eleStr != null ? double.parse(eleStr) : 0.0;
          return TracePointModel(
            latitude: lat,
            longitude: lon,
            elevation: elevation,
            time: time,
          );
        }).toList();

    return TraceModel(
      name: name,
      description: description,
      url: url,
      points: points,
    );
  }
}

class TracePointModel {
  final double latitude;
  final double longitude;
  final double? elevation;
  final DateTime? time;

  TracePointModel({
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.time,
  });

  static TracePointEntity toEntity(TracePointModel model) {
    return TracePointEntity(
      latitude: model.latitude,
      longitude: model.longitude,
      elevation: model.elevation,
      time: model.time,
    );
  }

  static TracePointModel fromEntity(TracePointEntity entity) {
    return TracePointModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      elevation: entity.elevation,
      time: entity.time,
    );
  }
}
