import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:openstreetmap/features/map/data/models/trace_model.dart';
import 'package:openstreetmap/features/map/data/mappers/trace_mapper.dart';

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
      final traces = tracks.map(TraceMapper.fromXml).toList();
      return traces;
    } else {
      throw Exception('Failed to load traces: ${response.statusCode}');
    }
  }
}
