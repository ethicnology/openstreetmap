import 'package:drift/drift.dart';
import 'package:openstreetmap/core/database/tables/activities_table.dart';

@DataClassName('ActivityPointsRow')
class ActivityPoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get elevation => real().nullable()();
  DateTimeColumn get time => dateTime()();
  TextColumn get activityId => text().references(Activities, #id)();
}
