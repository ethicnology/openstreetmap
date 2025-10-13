import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:openstreetmap/features/map/bloc/map_bloc.dart';
import 'package:openstreetmap/features/activities/bloc/activities_bloc.dart';
import 'package:openstreetmap/features/permissions/presentation/bloc/permissions_bloc.dart';
import 'package:openstreetmap/features/permissions/presentation/pages/check_permission_page.dart';
import 'core/locator.dart';

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
