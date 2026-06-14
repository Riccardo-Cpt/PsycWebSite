// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ArticoliTable extends Articoli
    with TableInfo<$ArticoliTable, ArticoliData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArticoliTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titoloMeta = const VerificationMeta('titolo');
  @override
  late final GeneratedColumn<String> titolo = GeneratedColumn<String>(
    'titolo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _corpoMeta = const VerificationMeta('corpo');
  @override
  late final GeneratedColumn<String> corpo = GeneratedColumn<String>(
    'corpo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataPubblicazioneMeta = const VerificationMeta(
    'dataPubblicazione',
  );
  @override
  late final GeneratedColumn<String> dataPubblicazione =
      GeneratedColumn<String>(
        'data_pubblicazione',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _pubblicatoAtMeta = const VerificationMeta(
    'pubblicatoAt',
  );
  @override
  late final GeneratedColumn<DateTime> pubblicatoAt = GeneratedColumn<DateTime>(
    'pubblicato_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _immagineMeta = const VerificationMeta(
    'immagine',
  );
  @override
  late final GeneratedColumn<Uint8List> immagine = GeneratedColumn<Uint8List>(
    'immagine',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _immagineMimeMeta = const VerificationMeta(
    'immagineMime',
  );
  @override
  late final GeneratedColumn<String> immagineMime = GeneratedColumn<String>(
    'immagine_mime',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    titolo,
    corpo,
    dataPubblicazione,
    pubblicatoAt,
    immagine,
    immagineMime,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'articoli';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArticoliData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('titolo')) {
      context.handle(
        _titoloMeta,
        titolo.isAcceptableOrUnknown(data['titolo']!, _titoloMeta),
      );
    } else if (isInserting) {
      context.missing(_titoloMeta);
    }
    if (data.containsKey('corpo')) {
      context.handle(
        _corpoMeta,
        corpo.isAcceptableOrUnknown(data['corpo']!, _corpoMeta),
      );
    } else if (isInserting) {
      context.missing(_corpoMeta);
    }
    if (data.containsKey('data_pubblicazione')) {
      context.handle(
        _dataPubblicazioneMeta,
        dataPubblicazione.isAcceptableOrUnknown(
          data['data_pubblicazione']!,
          _dataPubblicazioneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataPubblicazioneMeta);
    }
    if (data.containsKey('pubblicato_at')) {
      context.handle(
        _pubblicatoAtMeta,
        pubblicatoAt.isAcceptableOrUnknown(
          data['pubblicato_at']!,
          _pubblicatoAtMeta,
        ),
      );
    }
    if (data.containsKey('immagine')) {
      context.handle(
        _immagineMeta,
        immagine.isAcceptableOrUnknown(data['immagine']!, _immagineMeta),
      );
    }
    if (data.containsKey('immagine_mime')) {
      context.handle(
        _immagineMimeMeta,
        immagineMime.isAcceptableOrUnknown(
          data['immagine_mime']!,
          _immagineMimeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArticoliData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArticoliData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      titolo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titolo'],
      )!,
      corpo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}corpo'],
      )!,
      dataPubblicazione: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_pubblicazione'],
      )!,
      pubblicatoAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}pubblicato_at'],
      ),
      immagine: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}immagine'],
      ),
      immagineMime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}immagine_mime'],
      ),
    );
  }

  @override
  $ArticoliTable createAlias(String alias) {
    return $ArticoliTable(attachedDatabase, alias);
  }
}

class ArticoliData extends DataClass implements Insertable<ArticoliData> {
  final int id;
  final String titolo;
  final String corpo;
  final String dataPubblicazione;
  final DateTime? pubblicatoAt;
  final Uint8List? immagine;
  final String? immagineMime;
  const ArticoliData({
    required this.id,
    required this.titolo,
    required this.corpo,
    required this.dataPubblicazione,
    this.pubblicatoAt,
    this.immagine,
    this.immagineMime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['titolo'] = Variable<String>(titolo);
    map['corpo'] = Variable<String>(corpo);
    map['data_pubblicazione'] = Variable<String>(dataPubblicazione);
    if (!nullToAbsent || pubblicatoAt != null) {
      map['pubblicato_at'] = Variable<DateTime>(pubblicatoAt);
    }
    if (!nullToAbsent || immagine != null) {
      map['immagine'] = Variable<Uint8List>(immagine);
    }
    if (!nullToAbsent || immagineMime != null) {
      map['immagine_mime'] = Variable<String>(immagineMime);
    }
    return map;
  }

  ArticoliCompanion toCompanion(bool nullToAbsent) {
    return ArticoliCompanion(
      id: Value(id),
      titolo: Value(titolo),
      corpo: Value(corpo),
      dataPubblicazione: Value(dataPubblicazione),
      pubblicatoAt: pubblicatoAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pubblicatoAt),
      immagine: immagine == null && nullToAbsent
          ? const Value.absent()
          : Value(immagine),
      immagineMime: immagineMime == null && nullToAbsent
          ? const Value.absent()
          : Value(immagineMime),
    );
  }

  factory ArticoliData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArticoliData(
      id: serializer.fromJson<int>(json['id']),
      titolo: serializer.fromJson<String>(json['titolo']),
      corpo: serializer.fromJson<String>(json['corpo']),
      dataPubblicazione: serializer.fromJson<String>(json['dataPubblicazione']),
      pubblicatoAt: serializer.fromJson<DateTime?>(json['pubblicatoAt']),
      immagine: serializer.fromJson<Uint8List?>(json['immagine']),
      immagineMime: serializer.fromJson<String?>(json['immagineMime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'titolo': serializer.toJson<String>(titolo),
      'corpo': serializer.toJson<String>(corpo),
      'dataPubblicazione': serializer.toJson<String>(dataPubblicazione),
      'pubblicatoAt': serializer.toJson<DateTime?>(pubblicatoAt),
      'immagine': serializer.toJson<Uint8List?>(immagine),
      'immagineMime': serializer.toJson<String?>(immagineMime),
    };
  }

  ArticoliData copyWith({
    int? id,
    String? titolo,
    String? corpo,
    String? dataPubblicazione,
    Value<DateTime?> pubblicatoAt = const Value.absent(),
    Value<Uint8List?> immagine = const Value.absent(),
    Value<String?> immagineMime = const Value.absent(),
  }) => ArticoliData(
    id: id ?? this.id,
    titolo: titolo ?? this.titolo,
    corpo: corpo ?? this.corpo,
    dataPubblicazione: dataPubblicazione ?? this.dataPubblicazione,
    pubblicatoAt: pubblicatoAt.present ? pubblicatoAt.value : this.pubblicatoAt,
    immagine: immagine.present ? immagine.value : this.immagine,
    immagineMime: immagineMime.present ? immagineMime.value : this.immagineMime,
  );
  ArticoliData copyWithCompanion(ArticoliCompanion data) {
    return ArticoliData(
      id: data.id.present ? data.id.value : this.id,
      titolo: data.titolo.present ? data.titolo.value : this.titolo,
      corpo: data.corpo.present ? data.corpo.value : this.corpo,
      dataPubblicazione: data.dataPubblicazione.present
          ? data.dataPubblicazione.value
          : this.dataPubblicazione,
      pubblicatoAt: data.pubblicatoAt.present
          ? data.pubblicatoAt.value
          : this.pubblicatoAt,
      immagine: data.immagine.present ? data.immagine.value : this.immagine,
      immagineMime: data.immagineMime.present
          ? data.immagineMime.value
          : this.immagineMime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArticoliData(')
          ..write('id: $id, ')
          ..write('titolo: $titolo, ')
          ..write('corpo: $corpo, ')
          ..write('dataPubblicazione: $dataPubblicazione, ')
          ..write('pubblicatoAt: $pubblicatoAt, ')
          ..write('immagine: $immagine, ')
          ..write('immagineMime: $immagineMime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    titolo,
    corpo,
    dataPubblicazione,
    pubblicatoAt,
    $driftBlobEquality.hash(immagine),
    immagineMime,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArticoliData &&
          other.id == this.id &&
          other.titolo == this.titolo &&
          other.corpo == this.corpo &&
          other.dataPubblicazione == this.dataPubblicazione &&
          other.pubblicatoAt == this.pubblicatoAt &&
          $driftBlobEquality.equals(other.immagine, this.immagine) &&
          other.immagineMime == this.immagineMime);
}

class ArticoliCompanion extends UpdateCompanion<ArticoliData> {
  final Value<int> id;
  final Value<String> titolo;
  final Value<String> corpo;
  final Value<String> dataPubblicazione;
  final Value<DateTime?> pubblicatoAt;
  final Value<Uint8List?> immagine;
  final Value<String?> immagineMime;
  const ArticoliCompanion({
    this.id = const Value.absent(),
    this.titolo = const Value.absent(),
    this.corpo = const Value.absent(),
    this.dataPubblicazione = const Value.absent(),
    this.pubblicatoAt = const Value.absent(),
    this.immagine = const Value.absent(),
    this.immagineMime = const Value.absent(),
  });
  ArticoliCompanion.insert({
    this.id = const Value.absent(),
    required String titolo,
    required String corpo,
    required String dataPubblicazione,
    this.pubblicatoAt = const Value.absent(),
    this.immagine = const Value.absent(),
    this.immagineMime = const Value.absent(),
  }) : titolo = Value(titolo),
       corpo = Value(corpo),
       dataPubblicazione = Value(dataPubblicazione);
  static Insertable<ArticoliData> custom({
    Expression<int>? id,
    Expression<String>? titolo,
    Expression<String>? corpo,
    Expression<String>? dataPubblicazione,
    Expression<DateTime>? pubblicatoAt,
    Expression<Uint8List>? immagine,
    Expression<String>? immagineMime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (titolo != null) 'titolo': titolo,
      if (corpo != null) 'corpo': corpo,
      if (dataPubblicazione != null) 'data_pubblicazione': dataPubblicazione,
      if (pubblicatoAt != null) 'pubblicato_at': pubblicatoAt,
      if (immagine != null) 'immagine': immagine,
      if (immagineMime != null) 'immagine_mime': immagineMime,
    });
  }

  ArticoliCompanion copyWith({
    Value<int>? id,
    Value<String>? titolo,
    Value<String>? corpo,
    Value<String>? dataPubblicazione,
    Value<DateTime?>? pubblicatoAt,
    Value<Uint8List?>? immagine,
    Value<String?>? immagineMime,
  }) {
    return ArticoliCompanion(
      id: id ?? this.id,
      titolo: titolo ?? this.titolo,
      corpo: corpo ?? this.corpo,
      dataPubblicazione: dataPubblicazione ?? this.dataPubblicazione,
      pubblicatoAt: pubblicatoAt ?? this.pubblicatoAt,
      immagine: immagine ?? this.immagine,
      immagineMime: immagineMime ?? this.immagineMime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (titolo.present) {
      map['titolo'] = Variable<String>(titolo.value);
    }
    if (corpo.present) {
      map['corpo'] = Variable<String>(corpo.value);
    }
    if (dataPubblicazione.present) {
      map['data_pubblicazione'] = Variable<String>(dataPubblicazione.value);
    }
    if (pubblicatoAt.present) {
      map['pubblicato_at'] = Variable<DateTime>(pubblicatoAt.value);
    }
    if (immagine.present) {
      map['immagine'] = Variable<Uint8List>(immagine.value);
    }
    if (immagineMime.present) {
      map['immagine_mime'] = Variable<String>(immagineMime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticoliCompanion(')
          ..write('id: $id, ')
          ..write('titolo: $titolo, ')
          ..write('corpo: $corpo, ')
          ..write('dataPubblicazione: $dataPubblicazione, ')
          ..write('pubblicatoAt: $pubblicatoAt, ')
          ..write('immagine: $immagine, ')
          ..write('immagineMime: $immagineMime')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ArticoliTable articoli = $ArticoliTable(this);
  late final ArticoliDao articoliDao = ArticoliDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [articoli];
}

typedef $$ArticoliTableCreateCompanionBuilder =
    ArticoliCompanion Function({
      Value<int> id,
      required String titolo,
      required String corpo,
      required String dataPubblicazione,
      Value<DateTime?> pubblicatoAt,
      Value<Uint8List?> immagine,
      Value<String?> immagineMime,
    });
typedef $$ArticoliTableUpdateCompanionBuilder =
    ArticoliCompanion Function({
      Value<int> id,
      Value<String> titolo,
      Value<String> corpo,
      Value<String> dataPubblicazione,
      Value<DateTime?> pubblicatoAt,
      Value<Uint8List?> immagine,
      Value<String?> immagineMime,
    });

class $$ArticoliTableFilterComposer
    extends Composer<_$AppDatabase, $ArticoliTable> {
  $$ArticoliTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titolo => $composableBuilder(
    column: $table.titolo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get corpo => $composableBuilder(
    column: $table.corpo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataPubblicazione => $composableBuilder(
    column: $table.dataPubblicazione,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pubblicatoAt => $composableBuilder(
    column: $table.pubblicatoAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get immagine => $composableBuilder(
    column: $table.immagine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get immagineMime => $composableBuilder(
    column: $table.immagineMime,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ArticoliTableOrderingComposer
    extends Composer<_$AppDatabase, $ArticoliTable> {
  $$ArticoliTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titolo => $composableBuilder(
    column: $table.titolo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get corpo => $composableBuilder(
    column: $table.corpo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataPubblicazione => $composableBuilder(
    column: $table.dataPubblicazione,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pubblicatoAt => $composableBuilder(
    column: $table.pubblicatoAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get immagine => $composableBuilder(
    column: $table.immagine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get immagineMime => $composableBuilder(
    column: $table.immagineMime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArticoliTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArticoliTable> {
  $$ArticoliTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get titolo =>
      $composableBuilder(column: $table.titolo, builder: (column) => column);

  GeneratedColumn<String> get corpo =>
      $composableBuilder(column: $table.corpo, builder: (column) => column);

  GeneratedColumn<String> get dataPubblicazione => $composableBuilder(
    column: $table.dataPubblicazione,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get pubblicatoAt => $composableBuilder(
    column: $table.pubblicatoAt,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get immagine =>
      $composableBuilder(column: $table.immagine, builder: (column) => column);

  GeneratedColumn<String> get immagineMime => $composableBuilder(
    column: $table.immagineMime,
    builder: (column) => column,
  );
}

class $$ArticoliTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArticoliTable,
          ArticoliData,
          $$ArticoliTableFilterComposer,
          $$ArticoliTableOrderingComposer,
          $$ArticoliTableAnnotationComposer,
          $$ArticoliTableCreateCompanionBuilder,
          $$ArticoliTableUpdateCompanionBuilder,
          (
            ArticoliData,
            BaseReferences<_$AppDatabase, $ArticoliTable, ArticoliData>,
          ),
          ArticoliData,
          PrefetchHooks Function()
        > {
  $$ArticoliTableTableManager(_$AppDatabase db, $ArticoliTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArticoliTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArticoliTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArticoliTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> titolo = const Value.absent(),
                Value<String> corpo = const Value.absent(),
                Value<String> dataPubblicazione = const Value.absent(),
                Value<DateTime?> pubblicatoAt = const Value.absent(),
                Value<Uint8List?> immagine = const Value.absent(),
                Value<String?> immagineMime = const Value.absent(),
              }) => ArticoliCompanion(
                id: id,
                titolo: titolo,
                corpo: corpo,
                dataPubblicazione: dataPubblicazione,
                pubblicatoAt: pubblicatoAt,
                immagine: immagine,
                immagineMime: immagineMime,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String titolo,
                required String corpo,
                required String dataPubblicazione,
                Value<DateTime?> pubblicatoAt = const Value.absent(),
                Value<Uint8List?> immagine = const Value.absent(),
                Value<String?> immagineMime = const Value.absent(),
              }) => ArticoliCompanion.insert(
                id: id,
                titolo: titolo,
                corpo: corpo,
                dataPubblicazione: dataPubblicazione,
                pubblicatoAt: pubblicatoAt,
                immagine: immagine,
                immagineMime: immagineMime,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArticoliTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArticoliTable,
      ArticoliData,
      $$ArticoliTableFilterComposer,
      $$ArticoliTableOrderingComposer,
      $$ArticoliTableAnnotationComposer,
      $$ArticoliTableCreateCompanionBuilder,
      $$ArticoliTableUpdateCompanionBuilder,
      (
        ArticoliData,
        BaseReferences<_$AppDatabase, $ArticoliTable, ArticoliData>,
      ),
      ArticoliData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ArticoliTableTableManager get articoli =>
      $$ArticoliTableTableManager(_db, _db.articoli);
}
