// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AnimalsTable extends Animals with TableInfo<$AnimalsTable, Animal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesMeta = const VerificationMeta(
    'species',
  );
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
    'species',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('FEMALE'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ACTIVE'),
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tag,
    species,
    sex,
    status,
    birthDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'animals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Animal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    if (data.containsKey('species')) {
      context.handle(
        _speciesMeta,
        species.isAcceptableOrUnknown(data['species']!, _speciesMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesMeta);
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Animal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Animal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
      species: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species'],
      )!,
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AnimalsTable createAlias(String alias) {
    return $AnimalsTable(attachedDatabase, alias);
  }
}

class Animal extends DataClass implements Insertable<Animal> {
  final String id;
  final String tag;
  final String species;
  final String sex;
  final String status;
  final DateTime? birthDate;
  final DateTime createdAt;
  const Animal({
    required this.id,
    required this.tag,
    required this.species,
    required this.sex,
    required this.status,
    this.birthDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tag'] = Variable<String>(tag);
    map['species'] = Variable<String>(species);
    map['sex'] = Variable<String>(sex);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AnimalsCompanion toCompanion(bool nullToAbsent) {
    return AnimalsCompanion(
      id: Value(id),
      tag: Value(tag),
      species: Value(species),
      sex: Value(sex),
      status: Value(status),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      createdAt: Value(createdAt),
    );
  }

  factory Animal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Animal(
      id: serializer.fromJson<String>(json['id']),
      tag: serializer.fromJson<String>(json['tag']),
      species: serializer.fromJson<String>(json['species']),
      sex: serializer.fromJson<String>(json['sex']),
      status: serializer.fromJson<String>(json['status']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tag': serializer.toJson<String>(tag),
      'species': serializer.toJson<String>(species),
      'sex': serializer.toJson<String>(sex),
      'status': serializer.toJson<String>(status),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Animal copyWith({
    String? id,
    String? tag,
    String? species,
    String? sex,
    String? status,
    Value<DateTime?> birthDate = const Value.absent(),
    DateTime? createdAt,
  }) => Animal(
    id: id ?? this.id,
    tag: tag ?? this.tag,
    species: species ?? this.species,
    sex: sex ?? this.sex,
    status: status ?? this.status,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    createdAt: createdAt ?? this.createdAt,
  );
  Animal copyWithCompanion(AnimalsCompanion data) {
    return Animal(
      id: data.id.present ? data.id.value : this.id,
      tag: data.tag.present ? data.tag.value : this.tag,
      species: data.species.present ? data.species.value : this.species,
      sex: data.sex.present ? data.sex.value : this.sex,
      status: data.status.present ? data.status.value : this.status,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Animal(')
          ..write('id: $id, ')
          ..write('tag: $tag, ')
          ..write('species: $species, ')
          ..write('sex: $sex, ')
          ..write('status: $status, ')
          ..write('birthDate: $birthDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, tag, species, sex, status, birthDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Animal &&
          other.id == this.id &&
          other.tag == this.tag &&
          other.species == this.species &&
          other.sex == this.sex &&
          other.status == this.status &&
          other.birthDate == this.birthDate &&
          other.createdAt == this.createdAt);
}

class AnimalsCompanion extends UpdateCompanion<Animal> {
  final Value<String> id;
  final Value<String> tag;
  final Value<String> species;
  final Value<String> sex;
  final Value<String> status;
  final Value<DateTime?> birthDate;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AnimalsCompanion({
    this.id = const Value.absent(),
    this.tag = const Value.absent(),
    this.species = const Value.absent(),
    this.sex = const Value.absent(),
    this.status = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimalsCompanion.insert({
    required String id,
    required String tag,
    required String species,
    this.sex = const Value.absent(),
    this.status = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tag = Value(tag),
       species = Value(species);
  static Insertable<Animal> custom({
    Expression<String>? id,
    Expression<String>? tag,
    Expression<String>? species,
    Expression<String>? sex,
    Expression<String>? status,
    Expression<DateTime>? birthDate,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tag != null) 'tag': tag,
      if (species != null) 'species': species,
      if (sex != null) 'sex': sex,
      if (status != null) 'status': status,
      if (birthDate != null) 'birth_date': birthDate,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimalsCompanion copyWith({
    Value<String>? id,
    Value<String>? tag,
    Value<String>? species,
    Value<String>? sex,
    Value<String>? status,
    Value<DateTime?>? birthDate,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AnimalsCompanion(
      id: id ?? this.id,
      tag: tag ?? this.tag,
      species: species ?? this.species,
      sex: sex ?? this.sex,
      status: status ?? this.status,
      birthDate: birthDate ?? this.birthDate,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimalsCompanion(')
          ..write('id: $id, ')
          ..write('tag: $tag, ')
          ..write('species: $species, ')
          ..write('sex: $sex, ')
          ..write('status: $status, ')
          ..write('birthDate: $birthDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAlertsTable extends LocalAlerts
    with TableInfo<$LocalAlertsTable, LocalAlert> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _acknowledgedMeta = const VerificationMeta(
    'acknowledged',
  );
  @override
  late final GeneratedColumn<bool> acknowledged = GeneratedColumn<bool>(
    'acknowledged',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("acknowledged" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    severity,
    title,
    dueAt,
    acknowledged,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_alerts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAlert> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('acknowledged')) {
      context.handle(
        _acknowledgedMeta,
        acknowledged.isAcceptableOrUnknown(
          data['acknowledged']!,
          _acknowledgedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAlert map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAlert(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      acknowledged: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}acknowledged'],
      )!,
    );
  }

  @override
  $LocalAlertsTable createAlias(String alias) {
    return $LocalAlertsTable(attachedDatabase, alias);
  }
}

class LocalAlert extends DataClass implements Insertable<LocalAlert> {
  final String id;
  final String severity;
  final String title;
  final DateTime? dueAt;
  final bool acknowledged;
  const LocalAlert({
    required this.id,
    required this.severity,
    required this.title,
    this.dueAt,
    required this.acknowledged,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['severity'] = Variable<String>(severity);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    map['acknowledged'] = Variable<bool>(acknowledged);
    return map;
  }

  LocalAlertsCompanion toCompanion(bool nullToAbsent) {
    return LocalAlertsCompanion(
      id: Value(id),
      severity: Value(severity),
      title: Value(title),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      acknowledged: Value(acknowledged),
    );
  }

  factory LocalAlert.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAlert(
      id: serializer.fromJson<String>(json['id']),
      severity: serializer.fromJson<String>(json['severity']),
      title: serializer.fromJson<String>(json['title']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      acknowledged: serializer.fromJson<bool>(json['acknowledged']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'severity': serializer.toJson<String>(severity),
      'title': serializer.toJson<String>(title),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'acknowledged': serializer.toJson<bool>(acknowledged),
    };
  }

  LocalAlert copyWith({
    String? id,
    String? severity,
    String? title,
    Value<DateTime?> dueAt = const Value.absent(),
    bool? acknowledged,
  }) => LocalAlert(
    id: id ?? this.id,
    severity: severity ?? this.severity,
    title: title ?? this.title,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    acknowledged: acknowledged ?? this.acknowledged,
  );
  LocalAlert copyWithCompanion(LocalAlertsCompanion data) {
    return LocalAlert(
      id: data.id.present ? data.id.value : this.id,
      severity: data.severity.present ? data.severity.value : this.severity,
      title: data.title.present ? data.title.value : this.title,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      acknowledged: data.acknowledged.present
          ? data.acknowledged.value
          : this.acknowledged,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAlert(')
          ..write('id: $id, ')
          ..write('severity: $severity, ')
          ..write('title: $title, ')
          ..write('dueAt: $dueAt, ')
          ..write('acknowledged: $acknowledged')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, severity, title, dueAt, acknowledged);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAlert &&
          other.id == this.id &&
          other.severity == this.severity &&
          other.title == this.title &&
          other.dueAt == this.dueAt &&
          other.acknowledged == this.acknowledged);
}

class LocalAlertsCompanion extends UpdateCompanion<LocalAlert> {
  final Value<String> id;
  final Value<String> severity;
  final Value<String> title;
  final Value<DateTime?> dueAt;
  final Value<bool> acknowledged;
  final Value<int> rowid;
  const LocalAlertsCompanion({
    this.id = const Value.absent(),
    this.severity = const Value.absent(),
    this.title = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.acknowledged = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAlertsCompanion.insert({
    required String id,
    required String severity,
    required String title,
    this.dueAt = const Value.absent(),
    this.acknowledged = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       severity = Value(severity),
       title = Value(title);
  static Insertable<LocalAlert> custom({
    Expression<String>? id,
    Expression<String>? severity,
    Expression<String>? title,
    Expression<DateTime>? dueAt,
    Expression<bool>? acknowledged,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (severity != null) 'severity': severity,
      if (title != null) 'title': title,
      if (dueAt != null) 'due_at': dueAt,
      if (acknowledged != null) 'acknowledged': acknowledged,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAlertsCompanion copyWith({
    Value<String>? id,
    Value<String>? severity,
    Value<String>? title,
    Value<DateTime?>? dueAt,
    Value<bool>? acknowledged,
    Value<int>? rowid,
  }) {
    return LocalAlertsCompanion(
      id: id ?? this.id,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      dueAt: dueAt ?? this.dueAt,
      acknowledged: acknowledged ?? this.acknowledged,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (acknowledged.present) {
      map['acknowledged'] = Variable<bool>(acknowledged.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAlertsCompanion(')
          ..write('id: $id, ')
          ..write('severity: $severity, ')
          ..write('title: $title, ')
          ..write('dueAt: $dueAt, ')
          ..write('acknowledged: $acknowledged, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingOperationsTable extends PendingOperations
    with TableInfo<$PendingOperationsTable, PendingOperation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingOperationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, method, path, body, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingOperation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingOperation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingOperation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PendingOperationsTable createAlias(String alias) {
    return $PendingOperationsTable(attachedDatabase, alias);
  }
}

class PendingOperation extends DataClass
    implements Insertable<PendingOperation> {
  final int id;
  final String method;
  final String path;
  final String body;
  final DateTime createdAt;
  const PendingOperation({
    required this.id,
    required this.method,
    required this.path,
    required this.body,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['method'] = Variable<String>(method);
    map['path'] = Variable<String>(path);
    map['body'] = Variable<String>(body);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingOperationsCompanion toCompanion(bool nullToAbsent) {
    return PendingOperationsCompanion(
      id: Value(id),
      method: Value(method),
      path: Value(path),
      body: Value(body),
      createdAt: Value(createdAt),
    );
  }

  factory PendingOperation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingOperation(
      id: serializer.fromJson<int>(json['id']),
      method: serializer.fromJson<String>(json['method']),
      path: serializer.fromJson<String>(json['path']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'method': serializer.toJson<String>(method),
      'path': serializer.toJson<String>(path),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingOperation copyWith({
    int? id,
    String? method,
    String? path,
    String? body,
    DateTime? createdAt,
  }) => PendingOperation(
    id: id ?? this.id,
    method: method ?? this.method,
    path: path ?? this.path,
    body: body ?? this.body,
    createdAt: createdAt ?? this.createdAt,
  );
  PendingOperation copyWithCompanion(PendingOperationsCompanion data) {
    return PendingOperation(
      id: data.id.present ? data.id.value : this.id,
      method: data.method.present ? data.method.value : this.method,
      path: data.path.present ? data.path.value : this.path,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingOperation(')
          ..write('id: $id, ')
          ..write('method: $method, ')
          ..write('path: $path, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, method, path, body, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingOperation &&
          other.id == this.id &&
          other.method == this.method &&
          other.path == this.path &&
          other.body == this.body &&
          other.createdAt == this.createdAt);
}

class PendingOperationsCompanion extends UpdateCompanion<PendingOperation> {
  final Value<int> id;
  final Value<String> method;
  final Value<String> path;
  final Value<String> body;
  final Value<DateTime> createdAt;
  const PendingOperationsCompanion({
    this.id = const Value.absent(),
    this.method = const Value.absent(),
    this.path = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PendingOperationsCompanion.insert({
    this.id = const Value.absent(),
    required String method,
    required String path,
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : method = Value(method),
       path = Value(path);
  static Insertable<PendingOperation> custom({
    Expression<int>? id,
    Expression<String>? method,
    Expression<String>? path,
    Expression<String>? body,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (method != null) 'method': method,
      if (path != null) 'path': path,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PendingOperationsCompanion copyWith({
    Value<int>? id,
    Value<String>? method,
    Value<String>? path,
    Value<String>? body,
    Value<DateTime>? createdAt,
  }) {
    return PendingOperationsCompanion(
      id: id ?? this.id,
      method: method ?? this.method,
      path: path ?? this.path,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingOperationsCompanion(')
          ..write('id: $id, ')
          ..write('method: $method, ')
          ..write('path: $path, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $OutboxEventsTable extends OutboxEvents
    with TableInfo<$OutboxEventsTable, OutboxEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aggregateTypeMeta = const VerificationMeta(
    'aggregateType',
  );
  @override
  late final GeneratedColumn<String> aggregateType = GeneratedColumn<String>(
    'aggregate_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aggregateIdMeta = const VerificationMeta(
    'aggregateId',
  );
  @override
  late final GeneratedColumn<String> aggregateId = GeneratedColumn<String>(
    'aggregate_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventVersionMeta = const VerificationMeta(
    'eventVersion',
  );
  @override
  late final GeneratedColumn<int> eventVersion = GeneratedColumn<int>(
    'event_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
    'sent_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    aggregateType,
    aggregateId,
    eventType,
    eventVersion,
    occurredAt,
    payload,
    idempotencyKey,
    attempts,
    lastError,
    createdAt,
    sentAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('aggregate_type')) {
      context.handle(
        _aggregateTypeMeta,
        aggregateType.isAcceptableOrUnknown(
          data['aggregate_type']!,
          _aggregateTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggregateTypeMeta);
    }
    if (data.containsKey('aggregate_id')) {
      context.handle(
        _aggregateIdMeta,
        aggregateId.isAcceptableOrUnknown(
          data['aggregate_id']!,
          _aggregateIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggregateIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('event_version')) {
      context.handle(
        _eventVersionMeta,
        eventVersion.isAcceptableOrUnknown(
          data['event_version']!,
          _eventVersionMeta,
        ),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('sent_at')) {
      context.handle(
        _sentAtMeta,
        sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      aggregateType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aggregate_type'],
      )!,
      aggregateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aggregate_id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      eventVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_version'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      sentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sent_at'],
      ),
    );
  }

  @override
  $OutboxEventsTable createAlias(String alias) {
    return $OutboxEventsTable(attachedDatabase, alias);
  }
}

class OutboxEvent extends DataClass implements Insertable<OutboxEvent> {
  final String id;
  final String aggregateType;
  final String aggregateId;
  final String eventType;
  final int eventVersion;
  final DateTime occurredAt;
  final String payload;
  final String idempotencyKey;
  final int attempts;
  final String? lastError;
  final DateTime createdAt;
  final DateTime? sentAt;
  const OutboxEvent({
    required this.id,
    required this.aggregateType,
    required this.aggregateId,
    required this.eventType,
    required this.eventVersion,
    required this.occurredAt,
    required this.payload,
    required this.idempotencyKey,
    required this.attempts,
    this.lastError,
    required this.createdAt,
    this.sentAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['aggregate_type'] = Variable<String>(aggregateType);
    map['aggregate_id'] = Variable<String>(aggregateId);
    map['event_type'] = Variable<String>(eventType);
    map['event_version'] = Variable<int>(eventVersion);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['payload'] = Variable<String>(payload);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || sentAt != null) {
      map['sent_at'] = Variable<DateTime>(sentAt);
    }
    return map;
  }

  OutboxEventsCompanion toCompanion(bool nullToAbsent) {
    return OutboxEventsCompanion(
      id: Value(id),
      aggregateType: Value(aggregateType),
      aggregateId: Value(aggregateId),
      eventType: Value(eventType),
      eventVersion: Value(eventVersion),
      occurredAt: Value(occurredAt),
      payload: Value(payload),
      idempotencyKey: Value(idempotencyKey),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      sentAt: sentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(sentAt),
    );
  }

  factory OutboxEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEvent(
      id: serializer.fromJson<String>(json['id']),
      aggregateType: serializer.fromJson<String>(json['aggregateType']),
      aggregateId: serializer.fromJson<String>(json['aggregateId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      eventVersion: serializer.fromJson<int>(json['eventVersion']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      payload: serializer.fromJson<String>(json['payload']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      sentAt: serializer.fromJson<DateTime?>(json['sentAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'aggregateType': serializer.toJson<String>(aggregateType),
      'aggregateId': serializer.toJson<String>(aggregateId),
      'eventType': serializer.toJson<String>(eventType),
      'eventVersion': serializer.toJson<int>(eventVersion),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'payload': serializer.toJson<String>(payload),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'sentAt': serializer.toJson<DateTime?>(sentAt),
    };
  }

  OutboxEvent copyWith({
    String? id,
    String? aggregateType,
    String? aggregateId,
    String? eventType,
    int? eventVersion,
    DateTime? occurredAt,
    String? payload,
    String? idempotencyKey,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> sentAt = const Value.absent(),
  }) => OutboxEvent(
    id: id ?? this.id,
    aggregateType: aggregateType ?? this.aggregateType,
    aggregateId: aggregateId ?? this.aggregateId,
    eventType: eventType ?? this.eventType,
    eventVersion: eventVersion ?? this.eventVersion,
    occurredAt: occurredAt ?? this.occurredAt,
    payload: payload ?? this.payload,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    sentAt: sentAt.present ? sentAt.value : this.sentAt,
  );
  OutboxEvent copyWithCompanion(OutboxEventsCompanion data) {
    return OutboxEvent(
      id: data.id.present ? data.id.value : this.id,
      aggregateType: data.aggregateType.present
          ? data.aggregateType.value
          : this.aggregateType,
      aggregateId: data.aggregateId.present
          ? data.aggregateId.value
          : this.aggregateId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      eventVersion: data.eventVersion.present
          ? data.eventVersion.value
          : this.eventVersion,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      payload: data.payload.present ? data.payload.value : this.payload,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEvent(')
          ..write('id: $id, ')
          ..write('aggregateType: $aggregateType, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('eventType: $eventType, ')
          ..write('eventVersion: $eventVersion, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('payload: $payload, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('sentAt: $sentAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    aggregateType,
    aggregateId,
    eventType,
    eventVersion,
    occurredAt,
    payload,
    idempotencyKey,
    attempts,
    lastError,
    createdAt,
    sentAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEvent &&
          other.id == this.id &&
          other.aggregateType == this.aggregateType &&
          other.aggregateId == this.aggregateId &&
          other.eventType == this.eventType &&
          other.eventVersion == this.eventVersion &&
          other.occurredAt == this.occurredAt &&
          other.payload == this.payload &&
          other.idempotencyKey == this.idempotencyKey &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.sentAt == this.sentAt);
}

class OutboxEventsCompanion extends UpdateCompanion<OutboxEvent> {
  final Value<String> id;
  final Value<String> aggregateType;
  final Value<String> aggregateId;
  final Value<String> eventType;
  final Value<int> eventVersion;
  final Value<DateTime> occurredAt;
  final Value<String> payload;
  final Value<String> idempotencyKey;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime?> sentAt;
  final Value<int> rowid;
  const OutboxEventsCompanion({
    this.id = const Value.absent(),
    this.aggregateType = const Value.absent(),
    this.aggregateId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.eventVersion = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.payload = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxEventsCompanion.insert({
    required String id,
    required String aggregateType,
    required String aggregateId,
    required String eventType,
    this.eventVersion = const Value.absent(),
    required DateTime occurredAt,
    this.payload = const Value.absent(),
    required String idempotencyKey,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       aggregateType = Value(aggregateType),
       aggregateId = Value(aggregateId),
       eventType = Value(eventType),
       occurredAt = Value(occurredAt),
       idempotencyKey = Value(idempotencyKey);
  static Insertable<OutboxEvent> custom({
    Expression<String>? id,
    Expression<String>? aggregateType,
    Expression<String>? aggregateId,
    Expression<String>? eventType,
    Expression<int>? eventVersion,
    Expression<DateTime>? occurredAt,
    Expression<String>? payload,
    Expression<String>? idempotencyKey,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? sentAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (aggregateType != null) 'aggregate_type': aggregateType,
      if (aggregateId != null) 'aggregate_id': aggregateId,
      if (eventType != null) 'event_type': eventType,
      if (eventVersion != null) 'event_version': eventVersion,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (payload != null) 'payload': payload,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (sentAt != null) 'sent_at': sentAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? aggregateType,
    Value<String>? aggregateId,
    Value<String>? eventType,
    Value<int>? eventVersion,
    Value<DateTime>? occurredAt,
    Value<String>? payload,
    Value<String>? idempotencyKey,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime?>? sentAt,
    Value<int>? rowid,
  }) {
    return OutboxEventsCompanion(
      id: id ?? this.id,
      aggregateType: aggregateType ?? this.aggregateType,
      aggregateId: aggregateId ?? this.aggregateId,
      eventType: eventType ?? this.eventType,
      eventVersion: eventVersion ?? this.eventVersion,
      occurredAt: occurredAt ?? this.occurredAt,
      payload: payload ?? this.payload,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      sentAt: sentAt ?? this.sentAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (aggregateType.present) {
      map['aggregate_type'] = Variable<String>(aggregateType.value);
    }
    if (aggregateId.present) {
      map['aggregate_id'] = Variable<String>(aggregateId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (eventVersion.present) {
      map['event_version'] = Variable<int>(eventVersion.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEventsCompanion(')
          ..write('id: $id, ')
          ..write('aggregateType: $aggregateType, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('eventType: $eventType, ')
          ..write('eventVersion: $eventVersion, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('payload: $payload, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('sentAt: $sentAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStatesTable extends SyncStates
    with TableInfo<$SyncStatesTable, SyncState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _serverCursorMeta = const VerificationMeta(
    'serverCursor',
  );
  @override
  late final GeneratedColumn<int> serverCursor = GeneratedColumn<int>(
    'server_cursor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('IDLE'),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    serverCursor,
    lastSyncAt,
    status,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('server_cursor')) {
      context.handle(
        _serverCursorMeta,
        serverCursor.isAcceptableOrUnknown(
          data['server_cursor']!,
          _serverCursorMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncState(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      serverCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_cursor'],
      )!,
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncStatesTable createAlias(String alias) {
    return $SyncStatesTable(attachedDatabase, alias);
  }
}

class SyncState extends DataClass implements Insertable<SyncState> {
  final int id;
  final String deviceId;
  final int serverCursor;
  final DateTime? lastSyncAt;
  final String status;
  final String? lastError;
  const SyncState({
    required this.id,
    required this.deviceId,
    required this.serverCursor,
    this.lastSyncAt,
    required this.status,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['server_cursor'] = Variable<int>(serverCursor);
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncStatesCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      serverCursor: Value(serverCursor),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      status: Value(status),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncState(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      serverCursor: serializer.fromJson<int>(json['serverCursor']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      status: serializer.fromJson<String>(json['status']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'serverCursor': serializer.toJson<int>(serverCursor),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'status': serializer.toJson<String>(status),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncState copyWith({
    int? id,
    String? deviceId,
    int? serverCursor,
    Value<DateTime?> lastSyncAt = const Value.absent(),
    String? status,
    Value<String?> lastError = const Value.absent(),
  }) => SyncState(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    serverCursor: serverCursor ?? this.serverCursor,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
    status: status ?? this.status,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncState copyWithCompanion(SyncStatesCompanion data) {
    return SyncState(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      serverCursor: data.serverCursor.present
          ? data.serverCursor.value
          : this.serverCursor,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
      status: data.status.present ? data.status.value : this.status,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncState(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('serverCursor: $serverCursor, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('status: $status, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, deviceId, serverCursor, lastSyncAt, status, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncState &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.serverCursor == this.serverCursor &&
          other.lastSyncAt == this.lastSyncAt &&
          other.status == this.status &&
          other.lastError == this.lastError);
}

class SyncStatesCompanion extends UpdateCompanion<SyncState> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<int> serverCursor;
  final Value<DateTime?> lastSyncAt;
  final Value<String> status;
  final Value<String?> lastError;
  const SyncStatesCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.serverCursor = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.status = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  SyncStatesCompanion.insert({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.serverCursor = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.status = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  static Insertable<SyncState> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<int>? serverCursor,
    Expression<DateTime>? lastSyncAt,
    Expression<String>? status,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (serverCursor != null) 'server_cursor': serverCursor,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (status != null) 'status': status,
      if (lastError != null) 'last_error': lastError,
    });
  }

  SyncStatesCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<int>? serverCursor,
    Value<DateTime?>? lastSyncAt,
    Value<String>? status,
    Value<String?>? lastError,
  }) {
    return SyncStatesCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      serverCursor: serverCursor ?? this.serverCursor,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      status: status ?? this.status,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (serverCursor.present) {
      map['server_cursor'] = Variable<int>(serverCursor.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStatesCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('serverCursor: $serverCursor, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('status: $status, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $LocalLotsTable extends LocalLots
    with TableInfo<$LocalLotsTable, LocalLot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalLotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('OPEN'),
  );
  static const VerificationMeta _initialCountMeta = const VerificationMeta(
    'initialCount',
  );
  @override
  late final GeneratedColumn<int> initialCount = GeneratedColumn<int>(
    'initial_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currentCountMeta = const VerificationMeta(
    'currentCount',
  );
  @override
  late final GeneratedColumn<int> currentCount = GeneratedColumn<int>(
    'current_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    status,
    initialCount,
    currentCount,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_lots';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalLot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('initial_count')) {
      context.handle(
        _initialCountMeta,
        initialCount.isAcceptableOrUnknown(
          data['initial_count']!,
          _initialCountMeta,
        ),
      );
    }
    if (data.containsKey('current_count')) {
      context.handle(
        _currentCountMeta,
        currentCount.isAcceptableOrUnknown(
          data['current_count']!,
          _currentCountMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalLot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalLot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      initialCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_count'],
      )!,
      currentCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalLotsTable createAlias(String alias) {
    return $LocalLotsTable(attachedDatabase, alias);
  }
}

class LocalLot extends DataClass implements Insertable<LocalLot> {
  final String id;
  final String name;
  final String status;
  final int initialCount;
  final int currentCount;
  final DateTime updatedAt;
  const LocalLot({
    required this.id,
    required this.name,
    required this.status,
    required this.initialCount,
    required this.currentCount,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['status'] = Variable<String>(status);
    map['initial_count'] = Variable<int>(initialCount);
    map['current_count'] = Variable<int>(currentCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalLotsCompanion toCompanion(bool nullToAbsent) {
    return LocalLotsCompanion(
      id: Value(id),
      name: Value(name),
      status: Value(status),
      initialCount: Value(initialCount),
      currentCount: Value(currentCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalLot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalLot(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      status: serializer.fromJson<String>(json['status']),
      initialCount: serializer.fromJson<int>(json['initialCount']),
      currentCount: serializer.fromJson<int>(json['currentCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'status': serializer.toJson<String>(status),
      'initialCount': serializer.toJson<int>(initialCount),
      'currentCount': serializer.toJson<int>(currentCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalLot copyWith({
    String? id,
    String? name,
    String? status,
    int? initialCount,
    int? currentCount,
    DateTime? updatedAt,
  }) => LocalLot(
    id: id ?? this.id,
    name: name ?? this.name,
    status: status ?? this.status,
    initialCount: initialCount ?? this.initialCount,
    currentCount: currentCount ?? this.currentCount,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalLot copyWithCompanion(LocalLotsCompanion data) {
    return LocalLot(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      status: data.status.present ? data.status.value : this.status,
      initialCount: data.initialCount.present
          ? data.initialCount.value
          : this.initialCount,
      currentCount: data.currentCount.present
          ? data.currentCount.value
          : this.currentCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalLot(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('initialCount: $initialCount, ')
          ..write('currentCount: $currentCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, status, initialCount, currentCount, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalLot &&
          other.id == this.id &&
          other.name == this.name &&
          other.status == this.status &&
          other.initialCount == this.initialCount &&
          other.currentCount == this.currentCount &&
          other.updatedAt == this.updatedAt);
}

class LocalLotsCompanion extends UpdateCompanion<LocalLot> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> status;
  final Value<int> initialCount;
  final Value<int> currentCount;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalLotsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.initialCount = const Value.absent(),
    this.currentCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalLotsCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.initialCount = const Value.absent(),
    this.currentCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<LocalLot> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? status,
    Expression<int>? initialCount,
    Expression<int>? currentCount,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
      if (initialCount != null) 'initial_count': initialCount,
      if (currentCount != null) 'current_count': currentCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalLotsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? status,
    Value<int>? initialCount,
    Value<int>? currentCount,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalLotsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      initialCount: initialCount ?? this.initialCount,
      currentCount: currentCount ?? this.currentCount,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (initialCount.present) {
      map['initial_count'] = Variable<int>(initialCount.value);
    }
    if (currentCount.present) {
      map['current_count'] = Variable<int>(currentCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalLotsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('initialCount: $initialCount, ')
          ..write('currentCount: $currentCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalConflictsTable extends LocalConflicts
    with TableInfo<$LocalConflictsTable, LocalConflict> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _resolutionMeta = const VerificationMeta(
    'resolution',
  );
  @override
  late final GeneratedColumn<String> resolution = GeneratedColumn<String>(
    'resolution',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    reason,
    payload,
    resolution,
    createdAt,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalConflict> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('resolution')) {
      context.handle(
        _resolutionMeta,
        resolution.isAcceptableOrUnknown(data['resolution']!, _resolutionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalConflict map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalConflict(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      resolution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
    );
  }

  @override
  $LocalConflictsTable createAlias(String alias) {
    return $LocalConflictsTable(attachedDatabase, alias);
  }
}

class LocalConflict extends DataClass implements Insertable<LocalConflict> {
  final String id;
  final String entityType;
  final String entityId;
  final String reason;
  final String payload;
  final String? resolution;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  const LocalConflict({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.reason,
    required this.payload,
    this.resolution,
    required this.createdAt,
    this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['reason'] = Variable<String>(reason);
    map['payload'] = Variable<String>(payload);
    if (!nullToAbsent || resolution != null) {
      map['resolution'] = Variable<String>(resolution);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    return map;
  }

  LocalConflictsCompanion toCompanion(bool nullToAbsent) {
    return LocalConflictsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      reason: Value(reason),
      payload: Value(payload),
      resolution: resolution == null && nullToAbsent
          ? const Value.absent()
          : Value(resolution),
      createdAt: Value(createdAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
    );
  }

  factory LocalConflict.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalConflict(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      reason: serializer.fromJson<String>(json['reason']),
      payload: serializer.fromJson<String>(json['payload']),
      resolution: serializer.fromJson<String?>(json['resolution']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'reason': serializer.toJson<String>(reason),
      'payload': serializer.toJson<String>(payload),
      'resolution': serializer.toJson<String?>(resolution),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
    };
  }

  LocalConflict copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? reason,
    String? payload,
    Value<String?> resolution = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> resolvedAt = const Value.absent(),
  }) => LocalConflict(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    reason: reason ?? this.reason,
    payload: payload ?? this.payload,
    resolution: resolution.present ? resolution.value : this.resolution,
    createdAt: createdAt ?? this.createdAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
  );
  LocalConflict copyWithCompanion(LocalConflictsCompanion data) {
    return LocalConflict(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      reason: data.reason.present ? data.reason.value : this.reason,
      payload: data.payload.present ? data.payload.value : this.payload,
      resolution: data.resolution.present
          ? data.resolution.value
          : this.resolution,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalConflict(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('reason: $reason, ')
          ..write('payload: $payload, ')
          ..write('resolution: $resolution, ')
          ..write('createdAt: $createdAt, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    reason,
    payload,
    resolution,
    createdAt,
    resolvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalConflict &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.reason == this.reason &&
          other.payload == this.payload &&
          other.resolution == this.resolution &&
          other.createdAt == this.createdAt &&
          other.resolvedAt == this.resolvedAt);
}

class LocalConflictsCompanion extends UpdateCompanion<LocalConflict> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> reason;
  final Value<String> payload;
  final Value<String?> resolution;
  final Value<DateTime> createdAt;
  final Value<DateTime?> resolvedAt;
  final Value<int> rowid;
  const LocalConflictsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.reason = const Value.absent(),
    this.payload = const Value.absent(),
    this.resolution = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalConflictsCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    this.reason = const Value.absent(),
    this.payload = const Value.absent(),
    this.resolution = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId);
  static Insertable<LocalConflict> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? reason,
    Expression<String>? payload,
    Expression<String>? resolution,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? resolvedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (reason != null) 'reason': reason,
      if (payload != null) 'payload': payload,
      if (resolution != null) 'resolution': resolution,
      if (createdAt != null) 'created_at': createdAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalConflictsCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? reason,
    Value<String>? payload,
    Value<String?>? resolution,
    Value<DateTime>? createdAt,
    Value<DateTime?>? resolvedAt,
    Value<int>? rowid,
  }) {
    return LocalConflictsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      reason: reason ?? this.reason,
      payload: payload ?? this.payload,
      resolution: resolution ?? this.resolution,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (resolution.present) {
      map['resolution'] = Variable<String>(resolution.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalConflictsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('reason: $reason, ')
          ..write('payload: $payload, ')
          ..write('resolution: $resolution, ')
          ..write('createdAt: $createdAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AnimalsTable animals = $AnimalsTable(this);
  late final $LocalAlertsTable localAlerts = $LocalAlertsTable(this);
  late final $PendingOperationsTable pendingOperations =
      $PendingOperationsTable(this);
  late final $OutboxEventsTable outboxEvents = $OutboxEventsTable(this);
  late final $SyncStatesTable syncStates = $SyncStatesTable(this);
  late final $LocalLotsTable localLots = $LocalLotsTable(this);
  late final $LocalConflictsTable localConflicts = $LocalConflictsTable(this);
  late final AnimalDao animalDao = AnimalDao(this as AppDatabase);
  late final OutboxDao outboxDao = OutboxDao(this as AppDatabase);
  late final SyncStateDao syncStateDao = SyncStateDao(this as AppDatabase);
  late final LocalDataDao localDataDao = LocalDataDao(this as AppDatabase);
  late final ConflictDao conflictDao = ConflictDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    animals,
    localAlerts,
    pendingOperations,
    outboxEvents,
    syncStates,
    localLots,
    localConflicts,
  ];
}

typedef $$AnimalsTableCreateCompanionBuilder =
    AnimalsCompanion Function({
      required String id,
      required String tag,
      required String species,
      Value<String> sex,
      Value<String> status,
      Value<DateTime?> birthDate,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$AnimalsTableUpdateCompanionBuilder =
    AnimalsCompanion Function({
      Value<String> id,
      Value<String> tag,
      Value<String> species,
      Value<String> sex,
      Value<String> status,
      Value<DateTime?> birthDate,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AnimalsTableFilterComposer
    extends Composer<_$AppDatabase, $AnimalsTable> {
  $$AnimalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnimalsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnimalsTable> {
  $$AnimalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnimalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnimalsTable> {
  $$AnimalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AnimalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnimalsTable,
          Animal,
          $$AnimalsTableFilterComposer,
          $$AnimalsTableOrderingComposer,
          $$AnimalsTableAnnotationComposer,
          $$AnimalsTableCreateCompanionBuilder,
          $$AnimalsTableUpdateCompanionBuilder,
          (Animal, BaseReferences<_$AppDatabase, $AnimalsTable, Animal>),
          Animal,
          PrefetchHooks Function()
        > {
  $$AnimalsTableTableManager(_$AppDatabase db, $AnimalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnimalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tag = const Value.absent(),
                Value<String> species = const Value.absent(),
                Value<String> sex = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnimalsCompanion(
                id: id,
                tag: tag,
                species: species,
                sex: sex,
                status: status,
                birthDate: birthDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tag,
                required String species,
                Value<String> sex = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnimalsCompanion.insert(
                id: id,
                tag: tag,
                species: species,
                sex: sex,
                status: status,
                birthDate: birthDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnimalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnimalsTable,
      Animal,
      $$AnimalsTableFilterComposer,
      $$AnimalsTableOrderingComposer,
      $$AnimalsTableAnnotationComposer,
      $$AnimalsTableCreateCompanionBuilder,
      $$AnimalsTableUpdateCompanionBuilder,
      (Animal, BaseReferences<_$AppDatabase, $AnimalsTable, Animal>),
      Animal,
      PrefetchHooks Function()
    >;
typedef $$LocalAlertsTableCreateCompanionBuilder =
    LocalAlertsCompanion Function({
      required String id,
      required String severity,
      required String title,
      Value<DateTime?> dueAt,
      Value<bool> acknowledged,
      Value<int> rowid,
    });
typedef $$LocalAlertsTableUpdateCompanionBuilder =
    LocalAlertsCompanion Function({
      Value<String> id,
      Value<String> severity,
      Value<String> title,
      Value<DateTime?> dueAt,
      Value<bool> acknowledged,
      Value<int> rowid,
    });

class $$LocalAlertsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAlertsTable> {
  $$LocalAlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get acknowledged => $composableBuilder(
    column: $table.acknowledged,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAlertsTable> {
  $$LocalAlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get acknowledged => $composableBuilder(
    column: $table.acknowledged,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAlertsTable> {
  $$LocalAlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<bool> get acknowledged => $composableBuilder(
    column: $table.acknowledged,
    builder: (column) => column,
  );
}

class $$LocalAlertsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAlertsTable,
          LocalAlert,
          $$LocalAlertsTableFilterComposer,
          $$LocalAlertsTableOrderingComposer,
          $$LocalAlertsTableAnnotationComposer,
          $$LocalAlertsTableCreateCompanionBuilder,
          $$LocalAlertsTableUpdateCompanionBuilder,
          (
            LocalAlert,
            BaseReferences<_$AppDatabase, $LocalAlertsTable, LocalAlert>,
          ),
          LocalAlert,
          PrefetchHooks Function()
        > {
  $$LocalAlertsTableTableManager(_$AppDatabase db, $LocalAlertsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<bool> acknowledged = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAlertsCompanion(
                id: id,
                severity: severity,
                title: title,
                dueAt: dueAt,
                acknowledged: acknowledged,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String severity,
                required String title,
                Value<DateTime?> dueAt = const Value.absent(),
                Value<bool> acknowledged = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAlertsCompanion.insert(
                id: id,
                severity: severity,
                title: title,
                dueAt: dueAt,
                acknowledged: acknowledged,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAlertsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAlertsTable,
      LocalAlert,
      $$LocalAlertsTableFilterComposer,
      $$LocalAlertsTableOrderingComposer,
      $$LocalAlertsTableAnnotationComposer,
      $$LocalAlertsTableCreateCompanionBuilder,
      $$LocalAlertsTableUpdateCompanionBuilder,
      (
        LocalAlert,
        BaseReferences<_$AppDatabase, $LocalAlertsTable, LocalAlert>,
      ),
      LocalAlert,
      PrefetchHooks Function()
    >;
typedef $$PendingOperationsTableCreateCompanionBuilder =
    PendingOperationsCompanion Function({
      Value<int> id,
      required String method,
      required String path,
      Value<String> body,
      Value<DateTime> createdAt,
    });
typedef $$PendingOperationsTableUpdateCompanionBuilder =
    PendingOperationsCompanion Function({
      Value<int> id,
      Value<String> method,
      Value<String> path,
      Value<String> body,
      Value<DateTime> createdAt,
    });

class $$PendingOperationsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableFilterComposer({
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

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingOperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableOrderingComposer({
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

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingOperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PendingOperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingOperationsTable,
          PendingOperation,
          $$PendingOperationsTableFilterComposer,
          $$PendingOperationsTableOrderingComposer,
          $$PendingOperationsTableAnnotationComposer,
          $$PendingOperationsTableCreateCompanionBuilder,
          $$PendingOperationsTableUpdateCompanionBuilder,
          (
            PendingOperation,
            BaseReferences<
              _$AppDatabase,
              $PendingOperationsTable,
              PendingOperation
            >,
          ),
          PendingOperation,
          PrefetchHooks Function()
        > {
  $$PendingOperationsTableTableManager(
    _$AppDatabase db,
    $PendingOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingOperationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PendingOperationsCompanion(
                id: id,
                method: method,
                path: path,
                body: body,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String method,
                required String path,
                Value<String> body = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PendingOperationsCompanion.insert(
                id: id,
                method: method,
                path: path,
                body: body,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingOperationsTable,
      PendingOperation,
      $$PendingOperationsTableFilterComposer,
      $$PendingOperationsTableOrderingComposer,
      $$PendingOperationsTableAnnotationComposer,
      $$PendingOperationsTableCreateCompanionBuilder,
      $$PendingOperationsTableUpdateCompanionBuilder,
      (
        PendingOperation,
        BaseReferences<
          _$AppDatabase,
          $PendingOperationsTable,
          PendingOperation
        >,
      ),
      PendingOperation,
      PrefetchHooks Function()
    >;
typedef $$OutboxEventsTableCreateCompanionBuilder =
    OutboxEventsCompanion Function({
      required String id,
      required String aggregateType,
      required String aggregateId,
      required String eventType,
      Value<int> eventVersion,
      required DateTime occurredAt,
      Value<String> payload,
      required String idempotencyKey,
      Value<int> attempts,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime?> sentAt,
      Value<int> rowid,
    });
typedef $$OutboxEventsTableUpdateCompanionBuilder =
    OutboxEventsCompanion Function({
      Value<String> id,
      Value<String> aggregateType,
      Value<String> aggregateId,
      Value<String> eventType,
      Value<int> eventVersion,
      Value<DateTime> occurredAt,
      Value<String> payload,
      Value<String> idempotencyKey,
      Value<int> attempts,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime?> sentAt,
      Value<int> rowid,
    });

class $$OutboxEventsTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxEventsTable> {
  $$OutboxEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eventVersion => $composableBuilder(
    column: $table.eventVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxEventsTable> {
  $$OutboxEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eventVersion => $composableBuilder(
    column: $table.eventVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxEventsTable> {
  $$OutboxEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<int> get eventVersion => $composableBuilder(
    column: $table.eventVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);
}

class $$OutboxEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxEventsTable,
          OutboxEvent,
          $$OutboxEventsTableFilterComposer,
          $$OutboxEventsTableOrderingComposer,
          $$OutboxEventsTableAnnotationComposer,
          $$OutboxEventsTableCreateCompanionBuilder,
          $$OutboxEventsTableUpdateCompanionBuilder,
          (
            OutboxEvent,
            BaseReferences<_$AppDatabase, $OutboxEventsTable, OutboxEvent>,
          ),
          OutboxEvent,
          PrefetchHooks Function()
        > {
  $$OutboxEventsTableTableManager(_$AppDatabase db, $OutboxEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> aggregateType = const Value.absent(),
                Value<String> aggregateId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<int> eventVersion = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> sentAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxEventsCompanion(
                id: id,
                aggregateType: aggregateType,
                aggregateId: aggregateId,
                eventType: eventType,
                eventVersion: eventVersion,
                occurredAt: occurredAt,
                payload: payload,
                idempotencyKey: idempotencyKey,
                attempts: attempts,
                lastError: lastError,
                createdAt: createdAt,
                sentAt: sentAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String aggregateType,
                required String aggregateId,
                required String eventType,
                Value<int> eventVersion = const Value.absent(),
                required DateTime occurredAt,
                Value<String> payload = const Value.absent(),
                required String idempotencyKey,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> sentAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxEventsCompanion.insert(
                id: id,
                aggregateType: aggregateType,
                aggregateId: aggregateId,
                eventType: eventType,
                eventVersion: eventVersion,
                occurredAt: occurredAt,
                payload: payload,
                idempotencyKey: idempotencyKey,
                attempts: attempts,
                lastError: lastError,
                createdAt: createdAt,
                sentAt: sentAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxEventsTable,
      OutboxEvent,
      $$OutboxEventsTableFilterComposer,
      $$OutboxEventsTableOrderingComposer,
      $$OutboxEventsTableAnnotationComposer,
      $$OutboxEventsTableCreateCompanionBuilder,
      $$OutboxEventsTableUpdateCompanionBuilder,
      (
        OutboxEvent,
        BaseReferences<_$AppDatabase, $OutboxEventsTable, OutboxEvent>,
      ),
      OutboxEvent,
      PrefetchHooks Function()
    >;
typedef $$SyncStatesTableCreateCompanionBuilder =
    SyncStatesCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<int> serverCursor,
      Value<DateTime?> lastSyncAt,
      Value<String> status,
      Value<String?> lastError,
    });
typedef $$SyncStatesTableUpdateCompanionBuilder =
    SyncStatesCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<int> serverCursor,
      Value<DateTime?> lastSyncAt,
      Value<String> status,
      Value<String?> lastError,
    });

class $$SyncStatesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableFilterComposer({
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

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverCursor => $composableBuilder(
    column: $table.serverCursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableOrderingComposer({
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

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverCursor => $composableBuilder(
    column: $table.serverCursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get serverCursor => $composableBuilder(
    column: $table.serverCursor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStatesTable,
          SyncState,
          $$SyncStatesTableFilterComposer,
          $$SyncStatesTableOrderingComposer,
          $$SyncStatesTableAnnotationComposer,
          $$SyncStatesTableCreateCompanionBuilder,
          $$SyncStatesTableUpdateCompanionBuilder,
          (
            SyncState,
            BaseReferences<_$AppDatabase, $SyncStatesTable, SyncState>,
          ),
          SyncState,
          PrefetchHooks Function()
        > {
  $$SyncStatesTableTableManager(_$AppDatabase db, $SyncStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> serverCursor = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => SyncStatesCompanion(
                id: id,
                deviceId: deviceId,
                serverCursor: serverCursor,
                lastSyncAt: lastSyncAt,
                status: status,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> serverCursor = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => SyncStatesCompanion.insert(
                id: id,
                deviceId: deviceId,
                serverCursor: serverCursor,
                lastSyncAt: lastSyncAt,
                status: status,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStatesTable,
      SyncState,
      $$SyncStatesTableFilterComposer,
      $$SyncStatesTableOrderingComposer,
      $$SyncStatesTableAnnotationComposer,
      $$SyncStatesTableCreateCompanionBuilder,
      $$SyncStatesTableUpdateCompanionBuilder,
      (SyncState, BaseReferences<_$AppDatabase, $SyncStatesTable, SyncState>),
      SyncState,
      PrefetchHooks Function()
    >;
typedef $$LocalLotsTableCreateCompanionBuilder =
    LocalLotsCompanion Function({
      required String id,
      Value<String> name,
      Value<String> status,
      Value<int> initialCount,
      Value<int> currentCount,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalLotsTableUpdateCompanionBuilder =
    LocalLotsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> status,
      Value<int> initialCount,
      Value<int> currentCount,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalLotsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalLotsTable> {
  $$LocalLotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initialCount => $composableBuilder(
    column: $table.initialCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentCount => $composableBuilder(
    column: $table.currentCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalLotsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalLotsTable> {
  $$LocalLotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialCount => $composableBuilder(
    column: $table.initialCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentCount => $composableBuilder(
    column: $table.currentCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalLotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalLotsTable> {
  $$LocalLotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get initialCount => $composableBuilder(
    column: $table.initialCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentCount => $composableBuilder(
    column: $table.currentCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalLotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalLotsTable,
          LocalLot,
          $$LocalLotsTableFilterComposer,
          $$LocalLotsTableOrderingComposer,
          $$LocalLotsTableAnnotationComposer,
          $$LocalLotsTableCreateCompanionBuilder,
          $$LocalLotsTableUpdateCompanionBuilder,
          (LocalLot, BaseReferences<_$AppDatabase, $LocalLotsTable, LocalLot>),
          LocalLot,
          PrefetchHooks Function()
        > {
  $$LocalLotsTableTableManager(_$AppDatabase db, $LocalLotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalLotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalLotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalLotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> initialCount = const Value.absent(),
                Value<int> currentCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalLotsCompanion(
                id: id,
                name: name,
                status: status,
                initialCount: initialCount,
                currentCount: currentCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> name = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> initialCount = const Value.absent(),
                Value<int> currentCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalLotsCompanion.insert(
                id: id,
                name: name,
                status: status,
                initialCount: initialCount,
                currentCount: currentCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalLotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalLotsTable,
      LocalLot,
      $$LocalLotsTableFilterComposer,
      $$LocalLotsTableOrderingComposer,
      $$LocalLotsTableAnnotationComposer,
      $$LocalLotsTableCreateCompanionBuilder,
      $$LocalLotsTableUpdateCompanionBuilder,
      (LocalLot, BaseReferences<_$AppDatabase, $LocalLotsTable, LocalLot>),
      LocalLot,
      PrefetchHooks Function()
    >;
typedef $$LocalConflictsTableCreateCompanionBuilder =
    LocalConflictsCompanion Function({
      required String id,
      required String entityType,
      required String entityId,
      Value<String> reason,
      Value<String> payload,
      Value<String?> resolution,
      Value<DateTime> createdAt,
      Value<DateTime?> resolvedAt,
      Value<int> rowid,
    });
typedef $$LocalConflictsTableUpdateCompanionBuilder =
    LocalConflictsCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> reason,
      Value<String> payload,
      Value<String?> resolution,
      Value<DateTime> createdAt,
      Value<DateTime?> resolvedAt,
      Value<int> rowid,
    });

class $$LocalConflictsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalConflictsTable> {
  $$LocalConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalConflictsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalConflictsTable> {
  $$LocalConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalConflictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalConflictsTable> {
  $$LocalConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );
}

class $$LocalConflictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalConflictsTable,
          LocalConflict,
          $$LocalConflictsTableFilterComposer,
          $$LocalConflictsTableOrderingComposer,
          $$LocalConflictsTableAnnotationComposer,
          $$LocalConflictsTableCreateCompanionBuilder,
          $$LocalConflictsTableUpdateCompanionBuilder,
          (
            LocalConflict,
            BaseReferences<_$AppDatabase, $LocalConflictsTable, LocalConflict>,
          ),
          LocalConflict,
          PrefetchHooks Function()
        > {
  $$LocalConflictsTableTableManager(
    _$AppDatabase db,
    $LocalConflictsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalConflictsCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                reason: reason,
                payload: payload,
                resolution: resolution,
                createdAt: createdAt,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String entityId,
                Value<String> reason = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalConflictsCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                reason: reason,
                payload: payload,
                resolution: resolution,
                createdAt: createdAt,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalConflictsTable,
      LocalConflict,
      $$LocalConflictsTableFilterComposer,
      $$LocalConflictsTableOrderingComposer,
      $$LocalConflictsTableAnnotationComposer,
      $$LocalConflictsTableCreateCompanionBuilder,
      $$LocalConflictsTableUpdateCompanionBuilder,
      (
        LocalConflict,
        BaseReferences<_$AppDatabase, $LocalConflictsTable, LocalConflict>,
      ),
      LocalConflict,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AnimalsTableTableManager get animals =>
      $$AnimalsTableTableManager(_db, _db.animals);
  $$LocalAlertsTableTableManager get localAlerts =>
      $$LocalAlertsTableTableManager(_db, _db.localAlerts);
  $$PendingOperationsTableTableManager get pendingOperations =>
      $$PendingOperationsTableTableManager(_db, _db.pendingOperations);
  $$OutboxEventsTableTableManager get outboxEvents =>
      $$OutboxEventsTableTableManager(_db, _db.outboxEvents);
  $$SyncStatesTableTableManager get syncStates =>
      $$SyncStatesTableTableManager(_db, _db.syncStates);
  $$LocalLotsTableTableManager get localLots =>
      $$LocalLotsTableTableManager(_db, _db.localLots);
  $$LocalConflictsTableTableManager get localConflicts =>
      $$LocalConflictsTableTableManager(_db, _db.localConflicts);
}

mixin _$AnimalDaoMixin on DatabaseAccessor<AppDatabase> {
  $AnimalsTable get animals => attachedDatabase.animals;
  AnimalDaoManager get managers => AnimalDaoManager(this);
}

class AnimalDaoManager {
  final _$AnimalDaoMixin _db;
  AnimalDaoManager(this._db);
  $$AnimalsTableTableManager get animals =>
      $$AnimalsTableTableManager(_db.attachedDatabase, _db.animals);
}

mixin _$OutboxDaoMixin on DatabaseAccessor<AppDatabase> {
  $OutboxEventsTable get outboxEvents => attachedDatabase.outboxEvents;
  OutboxDaoManager get managers => OutboxDaoManager(this);
}

class OutboxDaoManager {
  final _$OutboxDaoMixin _db;
  OutboxDaoManager(this._db);
  $$OutboxEventsTableTableManager get outboxEvents =>
      $$OutboxEventsTableTableManager(_db.attachedDatabase, _db.outboxEvents);
}

mixin _$SyncStateDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncStatesTable get syncStates => attachedDatabase.syncStates;
  SyncStateDaoManager get managers => SyncStateDaoManager(this);
}

class SyncStateDaoManager {
  final _$SyncStateDaoMixin _db;
  SyncStateDaoManager(this._db);
  $$SyncStatesTableTableManager get syncStates =>
      $$SyncStatesTableTableManager(_db.attachedDatabase, _db.syncStates);
}

mixin _$LocalDataDaoMixin on DatabaseAccessor<AppDatabase> {
  $AnimalsTable get animals => attachedDatabase.animals;
  $LocalAlertsTable get localAlerts => attachedDatabase.localAlerts;
  $LocalLotsTable get localLots => attachedDatabase.localLots;
  LocalDataDaoManager get managers => LocalDataDaoManager(this);
}

class LocalDataDaoManager {
  final _$LocalDataDaoMixin _db;
  LocalDataDaoManager(this._db);
  $$AnimalsTableTableManager get animals =>
      $$AnimalsTableTableManager(_db.attachedDatabase, _db.animals);
  $$LocalAlertsTableTableManager get localAlerts =>
      $$LocalAlertsTableTableManager(_db.attachedDatabase, _db.localAlerts);
  $$LocalLotsTableTableManager get localLots =>
      $$LocalLotsTableTableManager(_db.attachedDatabase, _db.localLots);
}

mixin _$ConflictDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalConflictsTable get localConflicts => attachedDatabase.localConflicts;
  ConflictDaoManager get managers => ConflictDaoManager(this);
}

class ConflictDaoManager {
  final _$ConflictDaoMixin _db;
  ConflictDaoManager(this._db);
  $$LocalConflictsTableTableManager get localConflicts =>
      $$LocalConflictsTableTableManager(
        _db.attachedDatabase,
        _db.localConflicts,
      );
}
