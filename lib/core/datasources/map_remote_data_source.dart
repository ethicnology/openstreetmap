import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:furtive/core/database/tables/preferences_table.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

class MapRemoteDataSource {
  Future<Style> getMapConfig({
    MapThemeColumn theme = MapThemeColumn.light,
    MapLanguageColumn language = MapLanguageColumn.en,
  }) async {
    final url = dotenv.env['PROTOMAPS_URL'] ?? '';
    final key = dotenv.env['PROTOMAPS_KEY'] ?? '';
    if (url.isEmpty || key.isEmpty) {
      throw Exception('Missing PROTOMAPS_URL or PROTOMAPS_KEY in .env');
    }

    final styleUrl = '$url/${theme.name}/${language.name}.json?key=$key';
    return await StyleReader(uri: styleUrl, apiKey: key).read();
  }
}
