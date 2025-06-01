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

    if (response.statusCode == 200) {
      final document = XmlDocument.parse(response.body);
      final tracks = document.findAllElements('trk');
      final List<TraceModel> traces = [];

      for (final track in tracks) {
        final name = track.findElements('name').firstOrNull?.value ?? 'Unknown';
        final description = track.findElements('desc').firstOrNull?.value ?? '';
        final url = track.findElements('url').firstOrNull?.value ?? '';
        final trackPoints = track.findAllElements('trkpt');

        final points =
            trackPoints.map((point) {
              final lat = double.parse(point.getAttribute('lat')!);
              final lon = double.parse(point.getAttribute('lon')!);
              final eleElem = point.findElements('ele').firstOrNull;
              final timeElem = point.findElements('time').firstOrNull;
              return TracePointModel(
                latitude: lat,
                longitude: lon,
                elevation:
                    eleElem != null && eleElem.value != null
                        ? double.parse(eleElem.value!)
                        : null,
                time:
                    timeElem != null && timeElem.value != null
                        ? DateTime.parse(timeElem.value!)
                        : null,
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
      throw Exception('Failed to load track points');
    }
  }
}
