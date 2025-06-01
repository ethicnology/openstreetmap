import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:openstreetmap/features/map/data/models/trace_model.dart';

class TraceRemoteDataSource {
  Future<List<TraceModel>> getPublicTraces(
    double left,
    double bottom,
    double right,
    double top,
    int page,
  ) async {
    final uri = Uri.parse(
      'https://api.openstreetmap.org/api/0.6/trackpoints?bbox=$left,$bottom,$right,$top&page=$page',
    );
    final response = await http.get(uri);

    print(uri.toString());

    if (response.statusCode == 200) {
      final document = XmlDocument.parse(response.body);
      final tracks = document.findAllElements('trk');
      final List<TraceModel> traces = [];

      for (final track in tracks) {
        final name =
            track.findElements('name').firstOrNull?.innerText ?? 'Unknown';
        final description =
            track.findElements('desc').firstOrNull?.innerText ?? '';
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

        traces.add(
          TraceModel(
            name: name,
            description: description,
            url: url,
            points: points,
          ),
        );
      }

      return traces;
    } else {
      throw Exception('Failed to load traces: ${response.statusCode}');
    }
  }
}
