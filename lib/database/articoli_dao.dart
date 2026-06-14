import 'package:drift/drift.dart';
import 'app_database.dart';

part 'articoli_dao.g.dart';

@DriftAccessor(tables: [Articoli])
class ArticoliDao extends DatabaseAccessor<AppDatabase>
    with _$ArticoliDaoMixin {
  ArticoliDao(super.db);

  Future<List<ArticoliData>> tutti() =>
      (select(articoli)
            ..orderBy([
              (t) => OrderingTerm.desc(t.pubblicatoAt),
              (t) => OrderingTerm.desc(t.id),
            ]))
          .get();

  Stream<List<ArticoliData>> watchTutti() =>
      (select(articoli)
            ..orderBy([
              (t) => OrderingTerm.desc(t.pubblicatoAt),
              (t) => OrderingTerm.desc(t.id),
            ]))
          .watch();

  Future<int> inserisci(ArticoliCompanion articolo) =>
      into(articoli).insert(articolo);

  Future<void> aggiorna(ArticoliCompanion articolo) =>
      (update(articoli)..where((t) => t.id.equals(articolo.id.value)))
          .write(articolo);

  Future<void> cancella(int id) =>
      (delete(articoli)..where((t) => t.id.equals(id))).go();
}
