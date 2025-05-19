import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:openstreetmap/features/map/data/models/gps_track_point_model.dart';

class GpsTraceRemoteDataSource {
  Future<List<GpsTrackPointModel>> getPublicTraces(
    double left,
    double bottom,
    double right,
    double top,
    int page,
  ) async {
    final url =
        'https://api.openstreetmap.org/api/0.6/trackpoints?bbox=$left,$bottom,$right,$top&page=$page&limit=1000';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load GPS traces');
    }

    final xmlDoc = XmlDocument.parse(response.body);
    final points = <GpsTrackPointModel>[];
    for (final trkpt in xmlDoc.findAllElements('trkpt')) {
      final lat = double.parse(trkpt.getAttribute('lat')!);
      final lon = double.parse(trkpt.getAttribute('lon')!);
      final timeElem = trkpt.getElement('time');
      final time =
          timeElem != null && timeElem.value != null
              ? DateTime.tryParse(timeElem.value!)
              : null;
      points.add(GpsTrackPointModel(lat: lat, lon: lon, time: time));
    }
    return points;
  }
}
