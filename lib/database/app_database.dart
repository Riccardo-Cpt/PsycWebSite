import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'articoli_dao.dart';

part 'app_database.g.dart';

class Articoli extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get titolo => text()();
  TextColumn get corpo => text()();
  TextColumn get dataPubblicazione => text()(); // YYYY-MM-DD display string
  DateTimeColumn get pubblicatoAt => dateTime().nullable()(); // full timestamp for ordering
  BlobColumn get immagine => blob().nullable()();
  TextColumn get immagineMime => text().nullable()();
}

@DriftDatabase(tables: [Articoli], daos: [ArticoliDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openDatabase());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(articoli, articoli.pubblicatoAt);
          }
        },
      );

  static QueryExecutor _openDatabase() {
    return driftDatabase(
      name: 'psic_app_db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
