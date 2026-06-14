// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'articoli_dao.dart';

// ignore_for_file: type=lint
mixin _$ArticoliDaoMixin on DatabaseAccessor<AppDatabase> {
  $ArticoliTable get articoli => attachedDatabase.articoli;
  ArticoliDaoManager get managers => ArticoliDaoManager(this);
}

class ArticoliDaoManager {
  final _$ArticoliDaoMixin _db;
  ArticoliDaoManager(this._db);
  $$ArticoliTableTableManager get articoli =>
      $$ArticoliTableTableManager(_db.attachedDatabase, _db.articoli);
}
