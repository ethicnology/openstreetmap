import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_bloc.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_event.dart';
import 'core/locator/locator.dart';
import 'features/map/presentation/pages/map_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MapBloc>()..add(const FetchMap()),
      child: MaterialApp(
        title: 'Map App',
        theme: ThemeData.dark(),
        home: const MapPage(),
      ),
    );
  }
}
