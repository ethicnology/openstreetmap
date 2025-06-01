import 'package:xml/xml.dart';
import 'package:openstreetmap/features/map/data/models/trace_model.dart';
import 'package:openstreetmap/features/map/domain/entities/trace_entity.dart';

class TraceMapper {
  static TraceModel fromXml(XmlElement track) {
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

  static TraceEntity toEntity(TraceModel model) {
    return TraceEntity(
      name: model.name,
      description: model.description,
      url: model.url,
      points:
          model.points
              .map(
                (point) => TracePointEntity(
                  latitude: point.latitude,
                  longitude: point.longitude,
                  elevation: point.elevation,
                  time: point.time,
                ),
              )
              .toList(),
    );
  }

  static List<TraceEntity> toEntities(List<TraceModel> models) {
    return models.map(toEntity).toList();
  }

  static TraceModel fromEntity(TraceEntity entity) {
    return TraceModel(
      name: entity.name,
      description: entity.description,
      url: entity.url,
      points:
          entity.points
              .map(
                (point) => TracePointModel(
                  latitude: point.latitude,
                  longitude: point.longitude,
                  elevation: point.elevation,
                  time: point.time,
                ),
              )
              .toList(),
    );
  }

  static List<TraceModel> fromEntities(List<TraceEntity> entities) {
    return entities.map(fromEntity).toList();
  }
}
