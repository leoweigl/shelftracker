// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, BookEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publicationYearMeta = const VerificationMeta(
    'publicationYear',
  );
  @override
  late final GeneratedColumn<int> publicationYear = GeneratedColumn<int>(
    'publication_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userRatingMeta = const VerificationMeta(
    'userRating',
  );
  @override
  late final GeneratedColumn<double> userRating = GeneratedColumn<double>(
    'user_rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFinishedMeta = const VerificationMeta(
    'isFinished',
  );
  @override
  late final GeneratedColumn<bool> isFinished = GeneratedColumn<bool>(
    'is_finished',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_finished" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _keepBookMeta = const VerificationMeta(
    'keepBook',
  );
  @override
  late final GeneratedColumn<bool> keepBook = GeneratedColumn<bool>(
    'keep_book',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("keep_book" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    author,
    publicationYear,
    coverUrl,
    userRating,
    isFinished,
    keepBook,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    } else if (isInserting) {
      context.missing(_authorMeta);
    }
    if (data.containsKey('publication_year')) {
      context.handle(
        _publicationYearMeta,
        publicationYear.isAcceptableOrUnknown(
          data['publication_year']!,
          _publicationYearMeta,
        ),
      );
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('user_rating')) {
      context.handle(
        _userRatingMeta,
        userRating.isAcceptableOrUnknown(data['user_rating']!, _userRatingMeta),
      );
    }
    if (data.containsKey('is_finished')) {
      context.handle(
        _isFinishedMeta,
        isFinished.isAcceptableOrUnknown(data['is_finished']!, _isFinishedMeta),
      );
    }
    if (data.containsKey('keep_book')) {
      context.handle(
        _keepBookMeta,
        keepBook.isAcceptableOrUnknown(data['keep_book']!, _keepBookMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      publicationYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}publication_year'],
      ),
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      userRating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}user_rating'],
      ),
      isFinished: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_finished'],
      )!,
      keepBook: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}keep_book'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class BookEntry extends DataClass implements Insertable<BookEntry> {
  final int id;
  final String title;
  final String author;
  final int? publicationYear;
  final String? coverUrl;
  final double? userRating;
  final bool isFinished;
  final bool keepBook;
  final DateTime addedAt;
  const BookEntry({
    required this.id,
    required this.title,
    required this.author,
    this.publicationYear,
    this.coverUrl,
    this.userRating,
    required this.isFinished,
    required this.keepBook,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['author'] = Variable<String>(author);
    if (!nullToAbsent || publicationYear != null) {
      map['publication_year'] = Variable<int>(publicationYear);
    }
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || userRating != null) {
      map['user_rating'] = Variable<double>(userRating);
    }
    map['is_finished'] = Variable<bool>(isFinished);
    map['keep_book'] = Variable<bool>(keepBook);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      author: Value(author),
      publicationYear: publicationYear == null && nullToAbsent
          ? const Value.absent()
          : Value(publicationYear),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      userRating: userRating == null && nullToAbsent
          ? const Value.absent()
          : Value(userRating),
      isFinished: Value(isFinished),
      keepBook: Value(keepBook),
      addedAt: Value(addedAt),
    );
  }

  factory BookEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookEntry(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String>(json['author']),
      publicationYear: serializer.fromJson<int?>(json['publicationYear']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      userRating: serializer.fromJson<double?>(json['userRating']),
      isFinished: serializer.fromJson<bool>(json['isFinished']),
      keepBook: serializer.fromJson<bool>(json['keepBook']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String>(author),
      'publicationYear': serializer.toJson<int?>(publicationYear),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'userRating': serializer.toJson<double?>(userRating),
      'isFinished': serializer.toJson<bool>(isFinished),
      'keepBook': serializer.toJson<bool>(keepBook),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  BookEntry copyWith({
    int? id,
    String? title,
    String? author,
    Value<int?> publicationYear = const Value.absent(),
    Value<String?> coverUrl = const Value.absent(),
    Value<double?> userRating = const Value.absent(),
    bool? isFinished,
    bool? keepBook,
    DateTime? addedAt,
  }) => BookEntry(
    id: id ?? this.id,
    title: title ?? this.title,
    author: author ?? this.author,
    publicationYear: publicationYear.present
        ? publicationYear.value
        : this.publicationYear,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    userRating: userRating.present ? userRating.value : this.userRating,
    isFinished: isFinished ?? this.isFinished,
    keepBook: keepBook ?? this.keepBook,
    addedAt: addedAt ?? this.addedAt,
  );
  BookEntry copyWithCompanion(BooksCompanion data) {
    return BookEntry(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      publicationYear: data.publicationYear.present
          ? data.publicationYear.value
          : this.publicationYear,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      userRating: data.userRating.present
          ? data.userRating.value
          : this.userRating,
      isFinished: data.isFinished.present
          ? data.isFinished.value
          : this.isFinished,
      keepBook: data.keepBook.present ? data.keepBook.value : this.keepBook,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('publicationYear: $publicationYear, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('userRating: $userRating, ')
          ..write('isFinished: $isFinished, ')
          ..write('keepBook: $keepBook, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    author,
    publicationYear,
    coverUrl,
    userRating,
    isFinished,
    keepBook,
    addedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookEntry &&
          other.id == this.id &&
          other.title == this.title &&
          other.author == this.author &&
          other.publicationYear == this.publicationYear &&
          other.coverUrl == this.coverUrl &&
          other.userRating == this.userRating &&
          other.isFinished == this.isFinished &&
          other.keepBook == this.keepBook &&
          other.addedAt == this.addedAt);
}

class BooksCompanion extends UpdateCompanion<BookEntry> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> author;
  final Value<int?> publicationYear;
  final Value<String?> coverUrl;
  final Value<double?> userRating;
  final Value<bool> isFinished;
  final Value<bool> keepBook;
  final Value<DateTime> addedAt;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.publicationYear = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.userRating = const Value.absent(),
    this.isFinished = const Value.absent(),
    this.keepBook = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String author,
    this.publicationYear = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.userRating = const Value.absent(),
    this.isFinished = const Value.absent(),
    this.keepBook = const Value.absent(),
    this.addedAt = const Value.absent(),
  }) : title = Value(title),
       author = Value(author);
  static Insertable<BookEntry> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? author,
    Expression<int>? publicationYear,
    Expression<String>? coverUrl,
    Expression<double>? userRating,
    Expression<bool>? isFinished,
    Expression<bool>? keepBook,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (publicationYear != null) 'publication_year': publicationYear,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (userRating != null) 'user_rating': userRating,
      if (isFinished != null) 'is_finished': isFinished,
      if (keepBook != null) 'keep_book': keepBook,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  BooksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? author,
    Value<int?>? publicationYear,
    Value<String?>? coverUrl,
    Value<double?>? userRating,
    Value<bool>? isFinished,
    Value<bool>? keepBook,
    Value<DateTime>? addedAt,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      publicationYear: publicationYear ?? this.publicationYear,
      coverUrl: coverUrl ?? this.coverUrl,
      userRating: userRating ?? this.userRating,
      isFinished: isFinished ?? this.isFinished,
      keepBook: keepBook ?? this.keepBook,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (publicationYear.present) {
      map['publication_year'] = Variable<int>(publicationYear.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (userRating.present) {
      map['user_rating'] = Variable<double>(userRating.value);
    }
    if (isFinished.present) {
      map['is_finished'] = Variable<bool>(isFinished.value);
    }
    if (keepBook.present) {
      map['keep_book'] = Variable<bool>(keepBook.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('publicationYear: $publicationYear, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('userRating: $userRating, ')
          ..write('isFinished: $isFinished, ')
          ..write('keepBook: $keepBook, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [books];
}

typedef $$BooksTableCreateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      required String title,
      required String author,
      Value<int?> publicationYear,
      Value<String?> coverUrl,
      Value<double?> userRating,
      Value<bool> isFinished,
      Value<bool> keepBook,
      Value<DateTime> addedAt,
    });
typedef $$BooksTableUpdateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> author,
      Value<int?> publicationYear,
      Value<String?> coverUrl,
      Value<double?> userRating,
      Value<bool> isFinished,
      Value<bool> keepBook,
      Value<DateTime> addedAt,
    });

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get publicationYear => $composableBuilder(
    column: $table.publicationYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get userRating => $composableBuilder(
    column: $table.userRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFinished => $composableBuilder(
    column: $table.isFinished,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get keepBook => $composableBuilder(
    column: $table.keepBook,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get publicationYear => $composableBuilder(
    column: $table.publicationYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get userRating => $composableBuilder(
    column: $table.userRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFinished => $composableBuilder(
    column: $table.isFinished,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get keepBook => $composableBuilder(
    column: $table.keepBook,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<int> get publicationYear => $composableBuilder(
    column: $table.publicationYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<double> get userRating => $composableBuilder(
    column: $table.userRating,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFinished => $composableBuilder(
    column: $table.isFinished,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get keepBook =>
      $composableBuilder(column: $table.keepBook, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          BookEntry,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (BookEntry, BaseReferences<_$AppDatabase, $BooksTable, BookEntry>),
          BookEntry,
          PrefetchHooks Function()
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<int?> publicationYear = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<double?> userRating = const Value.absent(),
                Value<bool> isFinished = const Value.absent(),
                Value<bool> keepBook = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                title: title,
                author: author,
                publicationYear: publicationYear,
                coverUrl: coverUrl,
                userRating: userRating,
                isFinished: isFinished,
                keepBook: keepBook,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String author,
                Value<int?> publicationYear = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<double?> userRating = const Value.absent(),
                Value<bool> isFinished = const Value.absent(),
                Value<bool> keepBook = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                title: title,
                author: author,
                publicationYear: publicationYear,
                coverUrl: coverUrl,
                userRating: userRating,
                isFinished: isFinished,
                keepBook: keepBook,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      BookEntry,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (BookEntry, BaseReferences<_$AppDatabase, $BooksTable, BookEntry>),
      BookEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
}
