import 'package:injectable/injectable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

@LazySingleton()
class MapRemoteDataSource {
  Future<Style> getMapConfig() async {
    final url = dotenv.env['PROTOMAPS_URL'] ?? '';
    final key = dotenv.env['PROTOMAPS_KEY'] ?? '';
    if (url.isEmpty || key.isEmpty) {
      throw Exception('Missing PROTOMAPS_URL or PROTOMAPS_KEY in .env');
    }
    return await StyleReader(uri: '$url?key=$key', apiKey: key).read();
  }
}
