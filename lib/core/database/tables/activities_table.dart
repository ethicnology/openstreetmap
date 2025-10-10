import 'package:drift/drift.dart';

@DataClassName('ActivitiesRow')
class Activities extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get stoppedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
