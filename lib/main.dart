import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_bloc.dart';
import 'package:openstreetmap/features/activities/presentation/bloc/activities_bloc.dart';
import 'package:openstreetmap/features/permissions/presentation/bloc/permissions_bloc.dart';
import 'package:openstreetmap/features/permissions/presentation/pages/check_permission_page.dart';
import 'core/locator.dart';
import 'features/map/presentation/pages/map_page.dart';
import 'features/activities/presentation/pages/activities_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  Locator.setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<MapBloc>()),
        BlocProvider(create: (context) => getIt<ActivitiesBloc>()),
        BlocProvider(create: (context) => getIt<PermissionsBloc>()),
      ],
      child: MaterialApp(
        title: 'Map App',
        theme: ThemeData.dark(),
        home: const CheckPermissionPage(),
      ),
    );
  }
}

class BottomNavigationWidget extends StatefulWidget {
  const BottomNavigationWidget({super.key});

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  int _currentIndex = 0;

  final List<Widget> _pages = [const MapPage(), const ActivitiesListPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.black87,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Activities'),
        ],
      ),
    );
  }
}
