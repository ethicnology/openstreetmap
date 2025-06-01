import 'package:drift/drift.dart';
import 'trace_metadata_table.dart';

@DataClassName('TracePointRow')
class TracePoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get elevation => real().nullable()();
  DateTimeColumn get time => dateTime().nullable()();
  IntColumn get traceId => integer().references(TraceMetadatas, #id)();
}
