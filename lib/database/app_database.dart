import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('BookEntry')
class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get author => text()();
  IntColumn get publicationYear => integer().nullable()();
  TextColumn get coverUrl => text().nullable()();
  RealColumn get userRating => real().nullable()();
  BoolColumn get isFinished => boolean().withDefault(const Constant(false))();
  BoolColumn get keepBook => boolean().withDefault(const Constant(true))();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Books])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'shelftracker_db');
  }
}