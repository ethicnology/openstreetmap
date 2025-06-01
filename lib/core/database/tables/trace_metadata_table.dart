import 'package:drift/drift.dart';

@DataClassName('TraceMetadataRow')
class TraceMetadatas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get url => text()();
}
