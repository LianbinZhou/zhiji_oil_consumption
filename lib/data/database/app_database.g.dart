// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VehiclesTable extends Vehicles with TableInfo<$VehiclesTable, Vehicle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
      'brand', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
      'model', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _licensePlateMeta =
      const VerificationMeta('licensePlate');
  @override
  late final GeneratedColumn<String> licensePlate = GeneratedColumn<String>(
      'license_plate', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vehicleTypeMeta =
      const VerificationMeta('vehicleType');
  @override
  late final GeneratedColumn<String> vehicleType = GeneratedColumn<String>(
      'vehicle_type', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _energyTypeMeta =
      const VerificationMeta('energyType');
  @override
  late final GeneratedColumn<String> energyType = GeneratedColumn<String>(
      'energy_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(EnergyTypes.gasoline));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        brand,
        model,
        licensePlate,
        color,
        notes,
        vehicleType,
        isDefault,
        energyType,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(Insertable<Vehicle> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('brand')) {
      context.handle(
          _brandMeta, brand.isAcceptableOrUnknown(data['brand']!, _brandMeta));
    } else if (isInserting) {
      context.missing(_brandMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
          _modelMeta, model.isAcceptableOrUnknown(data['model']!, _modelMeta));
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('license_plate')) {
      context.handle(
          _licensePlateMeta,
          licensePlate.isAcceptableOrUnknown(
              data['license_plate']!, _licensePlateMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('vehicle_type')) {
      context.handle(
          _vehicleTypeMeta,
          vehicleType.isAcceptableOrUnknown(
              data['vehicle_type']!, _vehicleTypeMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('energy_type')) {
      context.handle(
          _energyTypeMeta,
          energyType.isAcceptableOrUnknown(
              data['energy_type']!, _energyTypeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vehicle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vehicle(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      brand: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand'])!,
      model: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model'])!,
      licensePlate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}license_plate']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      vehicleType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vehicle_type']),
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      energyType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}energy_type'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }
}

class Vehicle extends DataClass implements Insertable<Vehicle> {
  /// 主键 ID
  final int id;

  /// 车辆品牌
  final String brand;

  /// 车辆型号
  final String model;

  /// 车牌号码
  final String? licensePlate;

  /// 车辆颜色
  final String? color;

  /// 备注
  final String? notes;

  /// 车辆类型（轿车/SUV/MPV 等，说的是车身材质，不是能源）
  final String? vehicleType;

  /// 是否为默认车辆
  final bool isDefault;

  /// 【v4 新增】能源类型：gasoline / electric / hybrid
  /// 决定录入界面显示哪些字段、统计用哪套指标
  final String energyType;

  /// 创建时间（毫秒时间戳）
  final int createdAt;

  /// 更新时间（毫秒时间戳）
  final int updatedAt;
  const Vehicle(
      {required this.id,
      required this.brand,
      required this.model,
      this.licensePlate,
      this.color,
      this.notes,
      this.vehicleType,
      required this.isDefault,
      required this.energyType,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['brand'] = Variable<String>(brand);
    map['model'] = Variable<String>(model);
    if (!nullToAbsent || licensePlate != null) {
      map['license_plate'] = Variable<String>(licensePlate);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || vehicleType != null) {
      map['vehicle_type'] = Variable<String>(vehicleType);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['energy_type'] = Variable<String>(energyType);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      id: Value(id),
      brand: Value(brand),
      model: Value(model),
      licensePlate: licensePlate == null && nullToAbsent
          ? const Value.absent()
          : Value(licensePlate),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      vehicleType: vehicleType == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleType),
      isDefault: Value(isDefault),
      energyType: Value(energyType),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Vehicle.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vehicle(
      id: serializer.fromJson<int>(json['id']),
      brand: serializer.fromJson<String>(json['brand']),
      model: serializer.fromJson<String>(json['model']),
      licensePlate: serializer.fromJson<String?>(json['licensePlate']),
      color: serializer.fromJson<String?>(json['color']),
      notes: serializer.fromJson<String?>(json['notes']),
      vehicleType: serializer.fromJson<String?>(json['vehicleType']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      energyType: serializer.fromJson<String>(json['energyType']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'brand': serializer.toJson<String>(brand),
      'model': serializer.toJson<String>(model),
      'licensePlate': serializer.toJson<String?>(licensePlate),
      'color': serializer.toJson<String?>(color),
      'notes': serializer.toJson<String?>(notes),
      'vehicleType': serializer.toJson<String?>(vehicleType),
      'isDefault': serializer.toJson<bool>(isDefault),
      'energyType': serializer.toJson<String>(energyType),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Vehicle copyWith(
          {int? id,
          String? brand,
          String? model,
          Value<String?> licensePlate = const Value.absent(),
          Value<String?> color = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<String?> vehicleType = const Value.absent(),
          bool? isDefault,
          String? energyType,
          int? createdAt,
          int? updatedAt}) =>
      Vehicle(
        id: id ?? this.id,
        brand: brand ?? this.brand,
        model: model ?? this.model,
        licensePlate:
            licensePlate.present ? licensePlate.value : this.licensePlate,
        color: color.present ? color.value : this.color,
        notes: notes.present ? notes.value : this.notes,
        vehicleType: vehicleType.present ? vehicleType.value : this.vehicleType,
        isDefault: isDefault ?? this.isDefault,
        energyType: energyType ?? this.energyType,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Vehicle copyWithCompanion(VehiclesCompanion data) {
    return Vehicle(
      id: data.id.present ? data.id.value : this.id,
      brand: data.brand.present ? data.brand.value : this.brand,
      model: data.model.present ? data.model.value : this.model,
      licensePlate: data.licensePlate.present
          ? data.licensePlate.value
          : this.licensePlate,
      color: data.color.present ? data.color.value : this.color,
      notes: data.notes.present ? data.notes.value : this.notes,
      vehicleType:
          data.vehicleType.present ? data.vehicleType.value : this.vehicleType,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      energyType:
          data.energyType.present ? data.energyType.value : this.energyType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vehicle(')
          ..write('id: $id, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('licensePlate: $licensePlate, ')
          ..write('color: $color, ')
          ..write('notes: $notes, ')
          ..write('vehicleType: $vehicleType, ')
          ..write('isDefault: $isDefault, ')
          ..write('energyType: $energyType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, brand, model, licensePlate, color, notes,
      vehicleType, isDefault, energyType, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vehicle &&
          other.id == this.id &&
          other.brand == this.brand &&
          other.model == this.model &&
          other.licensePlate == this.licensePlate &&
          other.color == this.color &&
          other.notes == this.notes &&
          other.vehicleType == this.vehicleType &&
          other.isDefault == this.isDefault &&
          other.energyType == this.energyType &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VehiclesCompanion extends UpdateCompanion<Vehicle> {
  final Value<int> id;
  final Value<String> brand;
  final Value<String> model;
  final Value<String?> licensePlate;
  final Value<String?> color;
  final Value<String?> notes;
  final Value<String?> vehicleType;
  final Value<bool> isDefault;
  final Value<String> energyType;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const VehiclesCompanion({
    this.id = const Value.absent(),
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.licensePlate = const Value.absent(),
    this.color = const Value.absent(),
    this.notes = const Value.absent(),
    this.vehicleType = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.energyType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  VehiclesCompanion.insert({
    this.id = const Value.absent(),
    required String brand,
    required String model,
    this.licensePlate = const Value.absent(),
    this.color = const Value.absent(),
    this.notes = const Value.absent(),
    this.vehicleType = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.energyType = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  })  : brand = Value(brand),
        model = Value(model),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Vehicle> custom({
    Expression<int>? id,
    Expression<String>? brand,
    Expression<String>? model,
    Expression<String>? licensePlate,
    Expression<String>? color,
    Expression<String>? notes,
    Expression<String>? vehicleType,
    Expression<bool>? isDefault,
    Expression<String>? energyType,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (licensePlate != null) 'license_plate': licensePlate,
      if (color != null) 'color': color,
      if (notes != null) 'notes': notes,
      if (vehicleType != null) 'vehicle_type': vehicleType,
      if (isDefault != null) 'is_default': isDefault,
      if (energyType != null) 'energy_type': energyType,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  VehiclesCompanion copyWith(
      {Value<int>? id,
      Value<String>? brand,
      Value<String>? model,
      Value<String?>? licensePlate,
      Value<String?>? color,
      Value<String?>? notes,
      Value<String?>? vehicleType,
      Value<bool>? isDefault,
      Value<String>? energyType,
      Value<int>? createdAt,
      Value<int>? updatedAt}) {
    return VehiclesCompanion(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      licensePlate: licensePlate ?? this.licensePlate,
      color: color ?? this.color,
      notes: notes ?? this.notes,
      vehicleType: vehicleType ?? this.vehicleType,
      isDefault: isDefault ?? this.isDefault,
      energyType: energyType ?? this.energyType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (licensePlate.present) {
      map['license_plate'] = Variable<String>(licensePlate.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (vehicleType.present) {
      map['vehicle_type'] = Variable<String>(vehicleType.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (energyType.present) {
      map['energy_type'] = Variable<String>(energyType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCompanion(')
          ..write('id: $id, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('licensePlate: $licensePlate, ')
          ..write('color: $color, ')
          ..write('notes: $notes, ')
          ..write('vehicleType: $vehicleType, ')
          ..write('isDefault: $isDefault, ')
          ..write('energyType: $energyType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $EnergyRecordsTable extends EnergyRecords
    with TableInfo<$EnergyRecordsTable, EnergyRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnergyRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _vehicleIdMeta =
      const VerificationMeta('vehicleId');
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
      'vehicle_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES vehicles (id)'));
  static const VerificationMeta _energyTypeMeta =
      const VerificationMeta('energyType');
  @override
  late final GeneratedColumn<String> energyType = GeneratedColumn<String>(
      'energy_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(EnergyTypes.gasoline));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
      'date', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _discountMeta =
      const VerificationMeta('discount');
  @override
  late final GeneratedColumn<double> discount = GeneratedColumn<double>(
      'discount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
      'unit_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _odometerMeta =
      const VerificationMeta('odometer');
  @override
  late final GeneratedColumn<double> odometer = GeneratedColumn<double>(
      'odometer', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _isFullMeta = const VerificationMeta('isFull');
  @override
  late final GeneratedColumn<bool> isFull = GeneratedColumn<bool>(
      'is_full', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_full" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isLightOnMeta =
      const VerificationMeta('isLightOn');
  @override
  late final GeneratedColumn<bool> isLightOn = GeneratedColumn<bool>(
      'is_light_on', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_light_on" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _fuelTypeMeta =
      const VerificationMeta('fuelType');
  @override
  late final GeneratedColumn<String> fuelType = GeneratedColumn<String>(
      'fuel_type', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _chargeMethodMeta =
      const VerificationMeta('chargeMethod');
  @override
  late final GeneratedColumn<String> chargeMethod = GeneratedColumn<String>(
      'charge_method', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _stationNameMeta =
      const VerificationMeta('stationName');
  @override
  late final GeneratedColumn<String> stationName = GeneratedColumn<String>(
      'station_name', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        vehicleId,
        energyType,
        date,
        quantity,
        amount,
        discount,
        unitPrice,
        odometer,
        isFull,
        isLightOn,
        fuelType,
        chargeMethod,
        stationName,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'energy_records';
  @override
  VerificationContext validateIntegrity(Insertable<EnergyRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(_vehicleIdMeta,
          vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta));
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('energy_type')) {
      context.handle(
          _energyTypeMeta,
          energyType.isAcceptableOrUnknown(
              data['energy_type']!, _energyTypeMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('discount')) {
      context.handle(_discountMeta,
          discount.isAcceptableOrUnknown(data['discount']!, _discountMeta));
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('odometer')) {
      context.handle(_odometerMeta,
          odometer.isAcceptableOrUnknown(data['odometer']!, _odometerMeta));
    } else if (isInserting) {
      context.missing(_odometerMeta);
    }
    if (data.containsKey('is_full')) {
      context.handle(_isFullMeta,
          isFull.isAcceptableOrUnknown(data['is_full']!, _isFullMeta));
    }
    if (data.containsKey('is_light_on')) {
      context.handle(
          _isLightOnMeta,
          isLightOn.isAcceptableOrUnknown(
              data['is_light_on']!, _isLightOnMeta));
    }
    if (data.containsKey('fuel_type')) {
      context.handle(_fuelTypeMeta,
          fuelType.isAcceptableOrUnknown(data['fuel_type']!, _fuelTypeMeta));
    }
    if (data.containsKey('charge_method')) {
      context.handle(
          _chargeMethodMeta,
          chargeMethod.isAcceptableOrUnknown(
              data['charge_method']!, _chargeMethodMeta));
    }
    if (data.containsKey('station_name')) {
      context.handle(
          _stationNameMeta,
          stationName.isAcceptableOrUnknown(
              data['station_name']!, _stationNameMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnergyRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnergyRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      vehicleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vehicle_id'])!,
      energyType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}energy_type'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}date'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      discount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}discount'])!,
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_price'])!,
      odometer: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}odometer'])!,
      isFull: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_full'])!,
      isLightOn: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_light_on'])!,
      fuelType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fuel_type']),
      chargeMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}charge_method']),
      stationName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}station_name']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $EnergyRecordsTable createAlias(String alias) {
    return $EnergyRecordsTable(attachedDatabase, alias);
  }
}

class EnergyRecord extends DataClass implements Insertable<EnergyRecord> {
  final int id;

  /// 关联车辆
  final int vehicleId;

  /// 【v4 新增】这条记录是油还是电：gasoline / electric
  /// 注意：这是记录的"事实属性"，录入时按当时车辆类型写入，车辆改类型不回改历史
  final String energyType;

  /// 日期（毫秒时间戳）
  final int date;

  /// 数量：升（油）或 kWh（电）
  /// 【v4 改名】原 fuelAmount
  final double quantity;

  /// 实付金额（元）—— 统计（每公里成本、均价、总花费）都用这个
  /// 【v4 改名】原 totalPrice
  final double amount;

  /// 【v5 新增】优惠金额（元）
  /// 油站标价 743、实际付 700 → amount=700, discount=43
  /// 机显金额 = amount + discount（不单独存，避免三列互相矛盾）
  final double discount;

  /// 单价：元/升 或 元/kWh
  /// 【v4 改名】原 pricePerLiter
  final double unitPrice;

  /// 当前里程（公里）
  final double odometer;

  /// 是否加满 / 充满（锚点标记，能耗算法靠它分段）
  /// 【v4 改名】原 isFullTank
  final bool isFull;

  /// 是否油灯亮（仅油车，亮灯法锚点）
  final bool isLightOn;

  /// 油品标号（92#/95#/98#/柴油），仅油车
  final String? fuelType;

  /// 【v4 新增】充电方式：fast / slow / home，仅充电记录
  final String? chargeMethod;

  /// 加油站 / 充电站名称
  final String? stationName;

  /// 备注
  final String? notes;

  /// 创建时间（毫秒时间戳）
  final int createdAt;
  const EnergyRecord(
      {required this.id,
      required this.vehicleId,
      required this.energyType,
      required this.date,
      required this.quantity,
      required this.amount,
      required this.discount,
      required this.unitPrice,
      required this.odometer,
      required this.isFull,
      required this.isLightOn,
      this.fuelType,
      this.chargeMethod,
      this.stationName,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['energy_type'] = Variable<String>(energyType);
    map['date'] = Variable<int>(date);
    map['quantity'] = Variable<double>(quantity);
    map['amount'] = Variable<double>(amount);
    map['discount'] = Variable<double>(discount);
    map['unit_price'] = Variable<double>(unitPrice);
    map['odometer'] = Variable<double>(odometer);
    map['is_full'] = Variable<bool>(isFull);
    map['is_light_on'] = Variable<bool>(isLightOn);
    if (!nullToAbsent || fuelType != null) {
      map['fuel_type'] = Variable<String>(fuelType);
    }
    if (!nullToAbsent || chargeMethod != null) {
      map['charge_method'] = Variable<String>(chargeMethod);
    }
    if (!nullToAbsent || stationName != null) {
      map['station_name'] = Variable<String>(stationName);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  EnergyRecordsCompanion toCompanion(bool nullToAbsent) {
    return EnergyRecordsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      energyType: Value(energyType),
      date: Value(date),
      quantity: Value(quantity),
      amount: Value(amount),
      discount: Value(discount),
      unitPrice: Value(unitPrice),
      odometer: Value(odometer),
      isFull: Value(isFull),
      isLightOn: Value(isLightOn),
      fuelType: fuelType == null && nullToAbsent
          ? const Value.absent()
          : Value(fuelType),
      chargeMethod: chargeMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(chargeMethod),
      stationName: stationName == null && nullToAbsent
          ? const Value.absent()
          : Value(stationName),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory EnergyRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnergyRecord(
      id: serializer.fromJson<int>(json['id']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      energyType: serializer.fromJson<String>(json['energyType']),
      date: serializer.fromJson<int>(json['date']),
      quantity: serializer.fromJson<double>(json['quantity']),
      amount: serializer.fromJson<double>(json['amount']),
      discount: serializer.fromJson<double>(json['discount']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      odometer: serializer.fromJson<double>(json['odometer']),
      isFull: serializer.fromJson<bool>(json['isFull']),
      isLightOn: serializer.fromJson<bool>(json['isLightOn']),
      fuelType: serializer.fromJson<String?>(json['fuelType']),
      chargeMethod: serializer.fromJson<String?>(json['chargeMethod']),
      stationName: serializer.fromJson<String?>(json['stationName']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'energyType': serializer.toJson<String>(energyType),
      'date': serializer.toJson<int>(date),
      'quantity': serializer.toJson<double>(quantity),
      'amount': serializer.toJson<double>(amount),
      'discount': serializer.toJson<double>(discount),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'odometer': serializer.toJson<double>(odometer),
      'isFull': serializer.toJson<bool>(isFull),
      'isLightOn': serializer.toJson<bool>(isLightOn),
      'fuelType': serializer.toJson<String?>(fuelType),
      'chargeMethod': serializer.toJson<String?>(chargeMethod),
      'stationName': serializer.toJson<String?>(stationName),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  EnergyRecord copyWith(
          {int? id,
          int? vehicleId,
          String? energyType,
          int? date,
          double? quantity,
          double? amount,
          double? discount,
          double? unitPrice,
          double? odometer,
          bool? isFull,
          bool? isLightOn,
          Value<String?> fuelType = const Value.absent(),
          Value<String?> chargeMethod = const Value.absent(),
          Value<String?> stationName = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          int? createdAt}) =>
      EnergyRecord(
        id: id ?? this.id,
        vehicleId: vehicleId ?? this.vehicleId,
        energyType: energyType ?? this.energyType,
        date: date ?? this.date,
        quantity: quantity ?? this.quantity,
        amount: amount ?? this.amount,
        discount: discount ?? this.discount,
        unitPrice: unitPrice ?? this.unitPrice,
        odometer: odometer ?? this.odometer,
        isFull: isFull ?? this.isFull,
        isLightOn: isLightOn ?? this.isLightOn,
        fuelType: fuelType.present ? fuelType.value : this.fuelType,
        chargeMethod:
            chargeMethod.present ? chargeMethod.value : this.chargeMethod,
        stationName: stationName.present ? stationName.value : this.stationName,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  EnergyRecord copyWithCompanion(EnergyRecordsCompanion data) {
    return EnergyRecord(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      energyType:
          data.energyType.present ? data.energyType.value : this.energyType,
      date: data.date.present ? data.date.value : this.date,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      amount: data.amount.present ? data.amount.value : this.amount,
      discount: data.discount.present ? data.discount.value : this.discount,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      odometer: data.odometer.present ? data.odometer.value : this.odometer,
      isFull: data.isFull.present ? data.isFull.value : this.isFull,
      isLightOn: data.isLightOn.present ? data.isLightOn.value : this.isLightOn,
      fuelType: data.fuelType.present ? data.fuelType.value : this.fuelType,
      chargeMethod: data.chargeMethod.present
          ? data.chargeMethod.value
          : this.chargeMethod,
      stationName:
          data.stationName.present ? data.stationName.value : this.stationName,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnergyRecord(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('energyType: $energyType, ')
          ..write('date: $date, ')
          ..write('quantity: $quantity, ')
          ..write('amount: $amount, ')
          ..write('discount: $discount, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('odometer: $odometer, ')
          ..write('isFull: $isFull, ')
          ..write('isLightOn: $isLightOn, ')
          ..write('fuelType: $fuelType, ')
          ..write('chargeMethod: $chargeMethod, ')
          ..write('stationName: $stationName, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      vehicleId,
      energyType,
      date,
      quantity,
      amount,
      discount,
      unitPrice,
      odometer,
      isFull,
      isLightOn,
      fuelType,
      chargeMethod,
      stationName,
      notes,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnergyRecord &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.energyType == this.energyType &&
          other.date == this.date &&
          other.quantity == this.quantity &&
          other.amount == this.amount &&
          other.discount == this.discount &&
          other.unitPrice == this.unitPrice &&
          other.odometer == this.odometer &&
          other.isFull == this.isFull &&
          other.isLightOn == this.isLightOn &&
          other.fuelType == this.fuelType &&
          other.chargeMethod == this.chargeMethod &&
          other.stationName == this.stationName &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class EnergyRecordsCompanion extends UpdateCompanion<EnergyRecord> {
  final Value<int> id;
  final Value<int> vehicleId;
  final Value<String> energyType;
  final Value<int> date;
  final Value<double> quantity;
  final Value<double> amount;
  final Value<double> discount;
  final Value<double> unitPrice;
  final Value<double> odometer;
  final Value<bool> isFull;
  final Value<bool> isLightOn;
  final Value<String?> fuelType;
  final Value<String?> chargeMethod;
  final Value<String?> stationName;
  final Value<String?> notes;
  final Value<int> createdAt;
  const EnergyRecordsCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.energyType = const Value.absent(),
    this.date = const Value.absent(),
    this.quantity = const Value.absent(),
    this.amount = const Value.absent(),
    this.discount = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.odometer = const Value.absent(),
    this.isFull = const Value.absent(),
    this.isLightOn = const Value.absent(),
    this.fuelType = const Value.absent(),
    this.chargeMethod = const Value.absent(),
    this.stationName = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EnergyRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int vehicleId,
    this.energyType = const Value.absent(),
    required int date,
    required double quantity,
    required double amount,
    this.discount = const Value.absent(),
    required double unitPrice,
    required double odometer,
    this.isFull = const Value.absent(),
    this.isLightOn = const Value.absent(),
    this.fuelType = const Value.absent(),
    this.chargeMethod = const Value.absent(),
    this.stationName = const Value.absent(),
    this.notes = const Value.absent(),
    required int createdAt,
  })  : vehicleId = Value(vehicleId),
        date = Value(date),
        quantity = Value(quantity),
        amount = Value(amount),
        unitPrice = Value(unitPrice),
        odometer = Value(odometer),
        createdAt = Value(createdAt);
  static Insertable<EnergyRecord> custom({
    Expression<int>? id,
    Expression<int>? vehicleId,
    Expression<String>? energyType,
    Expression<int>? date,
    Expression<double>? quantity,
    Expression<double>? amount,
    Expression<double>? discount,
    Expression<double>? unitPrice,
    Expression<double>? odometer,
    Expression<bool>? isFull,
    Expression<bool>? isLightOn,
    Expression<String>? fuelType,
    Expression<String>? chargeMethod,
    Expression<String>? stationName,
    Expression<String>? notes,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (energyType != null) 'energy_type': energyType,
      if (date != null) 'date': date,
      if (quantity != null) 'quantity': quantity,
      if (amount != null) 'amount': amount,
      if (discount != null) 'discount': discount,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (odometer != null) 'odometer': odometer,
      if (isFull != null) 'is_full': isFull,
      if (isLightOn != null) 'is_light_on': isLightOn,
      if (fuelType != null) 'fuel_type': fuelType,
      if (chargeMethod != null) 'charge_method': chargeMethod,
      if (stationName != null) 'station_name': stationName,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EnergyRecordsCompanion copyWith(
      {Value<int>? id,
      Value<int>? vehicleId,
      Value<String>? energyType,
      Value<int>? date,
      Value<double>? quantity,
      Value<double>? amount,
      Value<double>? discount,
      Value<double>? unitPrice,
      Value<double>? odometer,
      Value<bool>? isFull,
      Value<bool>? isLightOn,
      Value<String?>? fuelType,
      Value<String?>? chargeMethod,
      Value<String?>? stationName,
      Value<String?>? notes,
      Value<int>? createdAt}) {
    return EnergyRecordsCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      energyType: energyType ?? this.energyType,
      date: date ?? this.date,
      quantity: quantity ?? this.quantity,
      amount: amount ?? this.amount,
      discount: discount ?? this.discount,
      unitPrice: unitPrice ?? this.unitPrice,
      odometer: odometer ?? this.odometer,
      isFull: isFull ?? this.isFull,
      isLightOn: isLightOn ?? this.isLightOn,
      fuelType: fuelType ?? this.fuelType,
      chargeMethod: chargeMethod ?? this.chargeMethod,
      stationName: stationName ?? this.stationName,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (energyType.present) {
      map['energy_type'] = Variable<String>(energyType.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (discount.present) {
      map['discount'] = Variable<double>(discount.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (odometer.present) {
      map['odometer'] = Variable<double>(odometer.value);
    }
    if (isFull.present) {
      map['is_full'] = Variable<bool>(isFull.value);
    }
    if (isLightOn.present) {
      map['is_light_on'] = Variable<bool>(isLightOn.value);
    }
    if (fuelType.present) {
      map['fuel_type'] = Variable<String>(fuelType.value);
    }
    if (chargeMethod.present) {
      map['charge_method'] = Variable<String>(chargeMethod.value);
    }
    if (stationName.present) {
      map['station_name'] = Variable<String>(stationName.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnergyRecordsCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('energyType: $energyType, ')
          ..write('date: $date, ')
          ..write('quantity: $quantity, ')
          ..write('amount: $amount, ')
          ..write('discount: $discount, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('odometer: $odometer, ')
          ..write('isFull: $isFull, ')
          ..write('isLightOn: $isLightOn, ')
          ..write('fuelType: $fuelType, ')
          ..write('chargeMethod: $chargeMethod, ')
          ..write('stationName: $stationName, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _vehicleIdMeta =
      const VerificationMeta('vehicleId');
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
      'vehicle_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES vehicles (id)'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
      'date', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 30),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _itemsMeta = const VerificationMeta('items');
  @override
  late final GeneratedColumn<String> items = GeneratedColumn<String>(
      'items', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mileageMeta =
      const VerificationMeta('mileage');
  @override
  late final GeneratedColumn<double> mileage = GeneratedColumn<double>(
      'mileage', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        vehicleId,
        date,
        kind,
        category,
        items,
        mileage,
        amount,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(Insertable<Expense> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(_vehicleIdMeta,
          vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta));
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('items')) {
      context.handle(
          _itemsMeta, items.isAcceptableOrUnknown(data['items']!, _itemsMeta));
    }
    if (data.containsKey('mileage')) {
      context.handle(_mileageMeta,
          mileage.isAcceptableOrUnknown(data['mileage']!, _mileageMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      vehicleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vehicle_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}date'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      items: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}items']),
      mileage: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}mileage']),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final int id;

  /// 关联车辆
  final int vehicleId;

  /// 日期（毫秒时间戳）
  final int date;

  /// 判别列：maintenance（保养）/ other（费用）
  final String kind;

  /// 细分类型
  /// - kind=maintenance 时：机油 / 刹车片 / 轮胎 ...（见 kMaintenanceItems）
  /// - kind=other 时：保险 / 停车费 / 维修 ...（见 kExpenseCategories）
  final String category;

  /// 保养项目，逗号分隔（仅保养用）
  final String? items;

  /// 当时里程（仅保养用）
  final double? mileage;

  /// 金额
  final double amount;

  /// 备注
  final String? notes;

  /// 创建时间（毫秒时间戳）
  final int createdAt;
  const Expense(
      {required this.id,
      required this.vehicleId,
      required this.date,
      required this.kind,
      required this.category,
      this.items,
      this.mileage,
      required this.amount,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['date'] = Variable<int>(date);
    map['kind'] = Variable<String>(kind);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || items != null) {
      map['items'] = Variable<String>(items);
    }
    if (!nullToAbsent || mileage != null) {
      map['mileage'] = Variable<double>(mileage);
    }
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      date: Value(date),
      kind: Value(kind),
      category: Value(category),
      items:
          items == null && nullToAbsent ? const Value.absent() : Value(items),
      mileage: mileage == null && nullToAbsent
          ? const Value.absent()
          : Value(mileage),
      amount: Value(amount),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<int>(json['id']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      date: serializer.fromJson<int>(json['date']),
      kind: serializer.fromJson<String>(json['kind']),
      category: serializer.fromJson<String>(json['category']),
      items: serializer.fromJson<String?>(json['items']),
      mileage: serializer.fromJson<double?>(json['mileage']),
      amount: serializer.fromJson<double>(json['amount']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'date': serializer.toJson<int>(date),
      'kind': serializer.toJson<String>(kind),
      'category': serializer.toJson<String>(category),
      'items': serializer.toJson<String?>(items),
      'mileage': serializer.toJson<double?>(mileage),
      'amount': serializer.toJson<double>(amount),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Expense copyWith(
          {int? id,
          int? vehicleId,
          int? date,
          String? kind,
          String? category,
          Value<String?> items = const Value.absent(),
          Value<double?> mileage = const Value.absent(),
          double? amount,
          Value<String?> notes = const Value.absent(),
          int? createdAt}) =>
      Expense(
        id: id ?? this.id,
        vehicleId: vehicleId ?? this.vehicleId,
        date: date ?? this.date,
        kind: kind ?? this.kind,
        category: category ?? this.category,
        items: items.present ? items.value : this.items,
        mileage: mileage.present ? mileage.value : this.mileage,
        amount: amount ?? this.amount,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      date: data.date.present ? data.date.value : this.date,
      kind: data.kind.present ? data.kind.value : this.kind,
      category: data.category.present ? data.category.value : this.category,
      items: data.items.present ? data.items.value : this.items,
      mileage: data.mileage.present ? data.mileage.value : this.mileage,
      amount: data.amount.present ? data.amount.value : this.amount,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('date: $date, ')
          ..write('kind: $kind, ')
          ..write('category: $category, ')
          ..write('items: $items, ')
          ..write('mileage: $mileage, ')
          ..write('amount: $amount, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, vehicleId, date, kind, category, items,
      mileage, amount, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.date == this.date &&
          other.kind == this.kind &&
          other.category == this.category &&
          other.items == this.items &&
          other.mileage == this.mileage &&
          other.amount == this.amount &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<int> id;
  final Value<int> vehicleId;
  final Value<int> date;
  final Value<String> kind;
  final Value<String> category;
  final Value<String?> items;
  final Value<double?> mileage;
  final Value<double> amount;
  final Value<String?> notes;
  final Value<int> createdAt;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.date = const Value.absent(),
    this.kind = const Value.absent(),
    this.category = const Value.absent(),
    this.items = const Value.absent(),
    this.mileage = const Value.absent(),
    this.amount = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.id = const Value.absent(),
    required int vehicleId,
    required int date,
    required String kind,
    required String category,
    this.items = const Value.absent(),
    this.mileage = const Value.absent(),
    required double amount,
    this.notes = const Value.absent(),
    required int createdAt,
  })  : vehicleId = Value(vehicleId),
        date = Value(date),
        kind = Value(kind),
        category = Value(category),
        amount = Value(amount),
        createdAt = Value(createdAt);
  static Insertable<Expense> custom({
    Expression<int>? id,
    Expression<int>? vehicleId,
    Expression<int>? date,
    Expression<String>? kind,
    Expression<String>? category,
    Expression<String>? items,
    Expression<double>? mileage,
    Expression<double>? amount,
    Expression<String>? notes,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (date != null) 'date': date,
      if (kind != null) 'kind': kind,
      if (category != null) 'category': category,
      if (items != null) 'items': items,
      if (mileage != null) 'mileage': mileage,
      if (amount != null) 'amount': amount,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ExpensesCompanion copyWith(
      {Value<int>? id,
      Value<int>? vehicleId,
      Value<int>? date,
      Value<String>? kind,
      Value<String>? category,
      Value<String?>? items,
      Value<double?>? mileage,
      Value<double>? amount,
      Value<String?>? notes,
      Value<int>? createdAt}) {
    return ExpensesCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      kind: kind ?? this.kind,
      category: category ?? this.category,
      items: items ?? this.items,
      mileage: mileage ?? this.mileage,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (items.present) {
      map['items'] = Variable<String>(items.value);
    }
    if (mileage.present) {
      map['mileage'] = Variable<double>(mileage.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('date: $date, ')
          ..write('kind: $kind, ')
          ..write('category: $category, ')
          ..write('items: $items, ')
          ..write('mileage: $mileage, ')
          ..write('amount: $amount, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  _$AppDatabase.connect(DatabaseConnection c) : super.connect(c);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $EnergyRecordsTable energyRecords = $EnergyRecordsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [vehicles, energyRecords, expenses];
}

typedef $$VehiclesTableCreateCompanionBuilder = VehiclesCompanion Function({
  Value<int> id,
  required String brand,
  required String model,
  Value<String?> licensePlate,
  Value<String?> color,
  Value<String?> notes,
  Value<String?> vehicleType,
  Value<bool> isDefault,
  Value<String> energyType,
  required int createdAt,
  required int updatedAt,
});
typedef $$VehiclesTableUpdateCompanionBuilder = VehiclesCompanion Function({
  Value<int> id,
  Value<String> brand,
  Value<String> model,
  Value<String?> licensePlate,
  Value<String?> color,
  Value<String?> notes,
  Value<String?> vehicleType,
  Value<bool> isDefault,
  Value<String> energyType,
  Value<int> createdAt,
  Value<int> updatedAt,
});

final class $$VehiclesTableReferences
    extends BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle> {
  $$VehiclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EnergyRecordsTable, List<EnergyRecord>>
      _energyRecordsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.energyRecords,
              aliasName: $_aliasNameGenerator(
                  db.vehicles.id, db.energyRecords.vehicleId));

  $$EnergyRecordsTableProcessedTableManager get energyRecordsRefs {
    final manager = $$EnergyRecordsTableTableManager($_db, $_db.energyRecords)
        .filter((f) => f.vehicleId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_energyRecordsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.expenses,
          aliasName:
              $_aliasNameGenerator(db.vehicles.id, db.expenses.vehicleId));

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager($_db, $_db.expenses)
        .filter((f) => f.vehicleId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$VehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get model => $composableBuilder(
      column: $table.model, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get licensePlate => $composableBuilder(
      column: $table.licensePlate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehicleType => $composableBuilder(
      column: $table.vehicleType, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get energyType => $composableBuilder(
      column: $table.energyType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> energyRecordsRefs(
      Expression<bool> Function($$EnergyRecordsTableFilterComposer f) f) {
    final $$EnergyRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.energyRecords,
        getReferencedColumn: (t) => t.vehicleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EnergyRecordsTableFilterComposer(
              $db: $db,
              $table: $db.energyRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> expensesRefs(
      Expression<bool> Function($$ExpensesTableFilterComposer f) f) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.vehicleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableFilterComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get model => $composableBuilder(
      column: $table.model, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get licensePlate => $composableBuilder(
      column: $table.licensePlate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehicleType => $composableBuilder(
      column: $table.vehicleType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get energyType => $composableBuilder(
      column: $table.energyType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get licensePlate => $composableBuilder(
      column: $table.licensePlate, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get vehicleType => $composableBuilder(
      column: $table.vehicleType, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<String> get energyType => $composableBuilder(
      column: $table.energyType, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> energyRecordsRefs<T extends Object>(
      Expression<T> Function($$EnergyRecordsTableAnnotationComposer a) f) {
    final $$EnergyRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.energyRecords,
        getReferencedColumn: (t) => t.vehicleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EnergyRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.energyRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
      Expression<T> Function($$ExpensesTableAnnotationComposer a) f) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.vehicleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableAnnotationComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VehiclesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VehiclesTable,
    Vehicle,
    $$VehiclesTableFilterComposer,
    $$VehiclesTableOrderingComposer,
    $$VehiclesTableAnnotationComposer,
    $$VehiclesTableCreateCompanionBuilder,
    $$VehiclesTableUpdateCompanionBuilder,
    (Vehicle, $$VehiclesTableReferences),
    Vehicle,
    PrefetchHooks Function({bool energyRecordsRefs, bool expensesRefs})> {
  $$VehiclesTableTableManager(_$AppDatabase db, $VehiclesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> brand = const Value.absent(),
            Value<String> model = const Value.absent(),
            Value<String?> licensePlate = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> vehicleType = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<String> energyType = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
          }) =>
              VehiclesCompanion(
            id: id,
            brand: brand,
            model: model,
            licensePlate: licensePlate,
            color: color,
            notes: notes,
            vehicleType: vehicleType,
            isDefault: isDefault,
            energyType: energyType,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String brand,
            required String model,
            Value<String?> licensePlate = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> vehicleType = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<String> energyType = const Value.absent(),
            required int createdAt,
            required int updatedAt,
          }) =>
              VehiclesCompanion.insert(
            id: id,
            brand: brand,
            model: model,
            licensePlate: licensePlate,
            color: color,
            notes: notes,
            vehicleType: vehicleType,
            isDefault: isDefault,
            energyType: energyType,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$VehiclesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {energyRecordsRefs = false, expensesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (energyRecordsRefs) db.energyRecords,
                if (expensesRefs) db.expenses
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (energyRecordsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$VehiclesTableReferences
                            ._energyRecordsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VehiclesTableReferences(db, table, p0)
                                .energyRecordsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.vehicleId == item.id),
                        typedResults: items),
                  if (expensesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$VehiclesTableReferences._expensesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VehiclesTableReferences(db, table, p0)
                                .expensesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.vehicleId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$VehiclesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VehiclesTable,
    Vehicle,
    $$VehiclesTableFilterComposer,
    $$VehiclesTableOrderingComposer,
    $$VehiclesTableAnnotationComposer,
    $$VehiclesTableCreateCompanionBuilder,
    $$VehiclesTableUpdateCompanionBuilder,
    (Vehicle, $$VehiclesTableReferences),
    Vehicle,
    PrefetchHooks Function({bool energyRecordsRefs, bool expensesRefs})>;
typedef $$EnergyRecordsTableCreateCompanionBuilder = EnergyRecordsCompanion
    Function({
  Value<int> id,
  required int vehicleId,
  Value<String> energyType,
  required int date,
  required double quantity,
  required double amount,
  Value<double> discount,
  required double unitPrice,
  required double odometer,
  Value<bool> isFull,
  Value<bool> isLightOn,
  Value<String?> fuelType,
  Value<String?> chargeMethod,
  Value<String?> stationName,
  Value<String?> notes,
  required int createdAt,
});
typedef $$EnergyRecordsTableUpdateCompanionBuilder = EnergyRecordsCompanion
    Function({
  Value<int> id,
  Value<int> vehicleId,
  Value<String> energyType,
  Value<int> date,
  Value<double> quantity,
  Value<double> amount,
  Value<double> discount,
  Value<double> unitPrice,
  Value<double> odometer,
  Value<bool> isFull,
  Value<bool> isLightOn,
  Value<String?> fuelType,
  Value<String?> chargeMethod,
  Value<String?> stationName,
  Value<String?> notes,
  Value<int> createdAt,
});

final class $$EnergyRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $EnergyRecordsTable, EnergyRecord> {
  $$EnergyRecordsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias(
          $_aliasNameGenerator(db.energyRecords.vehicleId, db.vehicles.id));

  $$VehiclesTableProcessedTableManager? get vehicleId {
    if ($_item.vehicleId == null) return null;
    final manager = $$VehiclesTableTableManager($_db, $_db.vehicles)
        .filter((f) => f.id($_item.vehicleId!));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$EnergyRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $EnergyRecordsTable> {
  $$EnergyRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get energyType => $composableBuilder(
      column: $table.energyType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get odometer => $composableBuilder(
      column: $table.odometer, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFull => $composableBuilder(
      column: $table.isFull, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isLightOn => $composableBuilder(
      column: $table.isLightOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fuelType => $composableBuilder(
      column: $table.fuelType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chargeMethod => $composableBuilder(
      column: $table.chargeMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stationName => $composableBuilder(
      column: $table.stationName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vehicleId,
        referencedTable: $db.vehicles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VehiclesTableFilterComposer(
              $db: $db,
              $table: $db.vehicles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EnergyRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $EnergyRecordsTable> {
  $$EnergyRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get energyType => $composableBuilder(
      column: $table.energyType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get odometer => $composableBuilder(
      column: $table.odometer, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFull => $composableBuilder(
      column: $table.isFull, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isLightOn => $composableBuilder(
      column: $table.isLightOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fuelType => $composableBuilder(
      column: $table.fuelType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chargeMethod => $composableBuilder(
      column: $table.chargeMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stationName => $composableBuilder(
      column: $table.stationName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vehicleId,
        referencedTable: $db.vehicles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VehiclesTableOrderingComposer(
              $db: $db,
              $table: $db.vehicles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EnergyRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnergyRecordsTable> {
  $$EnergyRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get energyType => $composableBuilder(
      column: $table.energyType, builder: (column) => column);

  GeneratedColumn<int> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get odometer =>
      $composableBuilder(column: $table.odometer, builder: (column) => column);

  GeneratedColumn<bool> get isFull =>
      $composableBuilder(column: $table.isFull, builder: (column) => column);

  GeneratedColumn<bool> get isLightOn =>
      $composableBuilder(column: $table.isLightOn, builder: (column) => column);

  GeneratedColumn<String> get fuelType =>
      $composableBuilder(column: $table.fuelType, builder: (column) => column);

  GeneratedColumn<String> get chargeMethod => $composableBuilder(
      column: $table.chargeMethod, builder: (column) => column);

  GeneratedColumn<String> get stationName => $composableBuilder(
      column: $table.stationName, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vehicleId,
        referencedTable: $db.vehicles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VehiclesTableAnnotationComposer(
              $db: $db,
              $table: $db.vehicles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EnergyRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EnergyRecordsTable,
    EnergyRecord,
    $$EnergyRecordsTableFilterComposer,
    $$EnergyRecordsTableOrderingComposer,
    $$EnergyRecordsTableAnnotationComposer,
    $$EnergyRecordsTableCreateCompanionBuilder,
    $$EnergyRecordsTableUpdateCompanionBuilder,
    (EnergyRecord, $$EnergyRecordsTableReferences),
    EnergyRecord,
    PrefetchHooks Function({bool vehicleId})> {
  $$EnergyRecordsTableTableManager(_$AppDatabase db, $EnergyRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnergyRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnergyRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnergyRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> vehicleId = const Value.absent(),
            Value<String> energyType = const Value.absent(),
            Value<int> date = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<double> discount = const Value.absent(),
            Value<double> unitPrice = const Value.absent(),
            Value<double> odometer = const Value.absent(),
            Value<bool> isFull = const Value.absent(),
            Value<bool> isLightOn = const Value.absent(),
            Value<String?> fuelType = const Value.absent(),
            Value<String?> chargeMethod = const Value.absent(),
            Value<String?> stationName = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              EnergyRecordsCompanion(
            id: id,
            vehicleId: vehicleId,
            energyType: energyType,
            date: date,
            quantity: quantity,
            amount: amount,
            discount: discount,
            unitPrice: unitPrice,
            odometer: odometer,
            isFull: isFull,
            isLightOn: isLightOn,
            fuelType: fuelType,
            chargeMethod: chargeMethod,
            stationName: stationName,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int vehicleId,
            Value<String> energyType = const Value.absent(),
            required int date,
            required double quantity,
            required double amount,
            Value<double> discount = const Value.absent(),
            required double unitPrice,
            required double odometer,
            Value<bool> isFull = const Value.absent(),
            Value<bool> isLightOn = const Value.absent(),
            Value<String?> fuelType = const Value.absent(),
            Value<String?> chargeMethod = const Value.absent(),
            Value<String?> stationName = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required int createdAt,
          }) =>
              EnergyRecordsCompanion.insert(
            id: id,
            vehicleId: vehicleId,
            energyType: energyType,
            date: date,
            quantity: quantity,
            amount: amount,
            discount: discount,
            unitPrice: unitPrice,
            odometer: odometer,
            isFull: isFull,
            isLightOn: isLightOn,
            fuelType: fuelType,
            chargeMethod: chargeMethod,
            stationName: stationName,
            notes: notes,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$EnergyRecordsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({vehicleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (vehicleId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.vehicleId,
                    referencedTable:
                        $$EnergyRecordsTableReferences._vehicleIdTable(db),
                    referencedColumn:
                        $$EnergyRecordsTableReferences._vehicleIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$EnergyRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EnergyRecordsTable,
    EnergyRecord,
    $$EnergyRecordsTableFilterComposer,
    $$EnergyRecordsTableOrderingComposer,
    $$EnergyRecordsTableAnnotationComposer,
    $$EnergyRecordsTableCreateCompanionBuilder,
    $$EnergyRecordsTableUpdateCompanionBuilder,
    (EnergyRecord, $$EnergyRecordsTableReferences),
    EnergyRecord,
    PrefetchHooks Function({bool vehicleId})>;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  required int vehicleId,
  required int date,
  required String kind,
  required String category,
  Value<String?> items,
  Value<double?> mileage,
  required double amount,
  Value<String?> notes,
  required int createdAt,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  Value<int> vehicleId,
  Value<int> date,
  Value<String> kind,
  Value<String> category,
  Value<String?> items,
  Value<double?> mileage,
  Value<double> amount,
  Value<String?> notes,
  Value<int> createdAt,
});

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, Expense> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) => db.vehicles
      .createAlias($_aliasNameGenerator(db.expenses.vehicleId, db.vehicles.id));

  $$VehiclesTableProcessedTableManager? get vehicleId {
    if ($_item.vehicleId == null) return null;
    final manager = $$VehiclesTableTableManager($_db, $_db.vehicles)
        .filter((f) => f.id($_item.vehicleId!));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get items => $composableBuilder(
      column: $table.items, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get mileage => $composableBuilder(
      column: $table.mileage, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vehicleId,
        referencedTable: $db.vehicles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VehiclesTableFilterComposer(
              $db: $db,
              $table: $db.vehicles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get items => $composableBuilder(
      column: $table.items, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get mileage => $composableBuilder(
      column: $table.mileage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vehicleId,
        referencedTable: $db.vehicles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VehiclesTableOrderingComposer(
              $db: $db,
              $table: $db.vehicles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get items =>
      $composableBuilder(column: $table.items, builder: (column) => column);

  GeneratedColumn<double> get mileage =>
      $composableBuilder(column: $table.mileage, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vehicleId,
        referencedTable: $db.vehicles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VehiclesTableAnnotationComposer(
              $db: $db,
              $table: $db.vehicles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpensesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpensesTable,
    Expense,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (Expense, $$ExpensesTableReferences),
    Expense,
    PrefetchHooks Function({bool vehicleId})> {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> vehicleId = const Value.absent(),
            Value<int> date = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> items = const Value.absent(),
            Value<double?> mileage = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              ExpensesCompanion(
            id: id,
            vehicleId: vehicleId,
            date: date,
            kind: kind,
            category: category,
            items: items,
            mileage: mileage,
            amount: amount,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int vehicleId,
            required int date,
            required String kind,
            required String category,
            Value<String?> items = const Value.absent(),
            Value<double?> mileage = const Value.absent(),
            required double amount,
            Value<String?> notes = const Value.absent(),
            required int createdAt,
          }) =>
              ExpensesCompanion.insert(
            id: id,
            vehicleId: vehicleId,
            date: date,
            kind: kind,
            category: category,
            items: items,
            mileage: mileage,
            amount: amount,
            notes: notes,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ExpensesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({vehicleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (vehicleId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.vehicleId,
                    referencedTable:
                        $$ExpensesTableReferences._vehicleIdTable(db),
                    referencedColumn:
                        $$ExpensesTableReferences._vehicleIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ExpensesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExpensesTable,
    Expense,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (Expense, $$ExpensesTableReferences),
    Expense,
    PrefetchHooks Function({bool vehicleId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$EnergyRecordsTableTableManager get energyRecords =>
      $$EnergyRecordsTableTableManager(_db, _db.energyRecords);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
}
