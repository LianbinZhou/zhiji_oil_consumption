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
  /// 主键ID
  /// autoIncrement()表示ID会自动递增,不需要手动设置
  final int id;

  /// 车辆品牌(必填)
  /// text()表示这是文本类型
  /// minLength(1)确保品牌名称不能为空
  final String brand;

  /// 车辆型号(必填)
  final String model;

  /// 车牌号码(可选)
  /// nullable()表示这个字段可以为空
  final String? licensePlate;

  /// 车辆颜色(可选)
  final String? color;

  /// 备注信息(可选)
  /// longerText()表示可以存储更长的文本
  final String? notes;

  /// 车辆类型(可选,如:轿车、SUV、MPV等)
  final String? vehicleType;

  /// 是否为默认车辆
  final bool isDefault;

  /// 创建时间
  /// 存储为整数(毫秒时间戳)
  final int createdAt;

  /// 更新时间
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
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, brand, model, licensePlate, color, notes,
      vehicleType, isDefault, createdAt, updatedAt);
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
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FuelRecordsTable extends FuelRecords
    with TableInfo<$FuelRecordsTable, FuelRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FuelRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _fuelAmountMeta =
      const VerificationMeta('fuelAmount');
  @override
  late final GeneratedColumn<double> fuelAmount = GeneratedColumn<double>(
      'fuel_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalPriceMeta =
      const VerificationMeta('totalPrice');
  @override
  late final GeneratedColumn<double> totalPrice = GeneratedColumn<double>(
      'total_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _pricePerLiterMeta =
      const VerificationMeta('pricePerLiter');
  @override
  late final GeneratedColumn<double> pricePerLiter = GeneratedColumn<double>(
      'price_per_liter', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _odometerMeta =
      const VerificationMeta('odometer');
  @override
  late final GeneratedColumn<double> odometer = GeneratedColumn<double>(
      'odometer', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _isFullTankMeta =
      const VerificationMeta('isFullTank');
  @override
  late final GeneratedColumn<bool> isFullTank = GeneratedColumn<bool>(
      'is_full_tank', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_full_tank" IN (0, 1))'),
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
        date,
        fuelAmount,
        totalPrice,
        pricePerLiter,
        odometer,
        isFullTank,
        isLightOn,
        fuelType,
        stationName,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fuel_records';
  @override
  VerificationContext validateIntegrity(Insertable<FuelRecord> instance,
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
    if (data.containsKey('fuel_amount')) {
      context.handle(
          _fuelAmountMeta,
          fuelAmount.isAcceptableOrUnknown(
              data['fuel_amount']!, _fuelAmountMeta));
    } else if (isInserting) {
      context.missing(_fuelAmountMeta);
    }
    if (data.containsKey('total_price')) {
      context.handle(
          _totalPriceMeta,
          totalPrice.isAcceptableOrUnknown(
              data['total_price']!, _totalPriceMeta));
    } else if (isInserting) {
      context.missing(_totalPriceMeta);
    }
    if (data.containsKey('price_per_liter')) {
      context.handle(
          _pricePerLiterMeta,
          pricePerLiter.isAcceptableOrUnknown(
              data['price_per_liter']!, _pricePerLiterMeta));
    } else if (isInserting) {
      context.missing(_pricePerLiterMeta);
    }
    if (data.containsKey('odometer')) {
      context.handle(_odometerMeta,
          odometer.isAcceptableOrUnknown(data['odometer']!, _odometerMeta));
    } else if (isInserting) {
      context.missing(_odometerMeta);
    }
    if (data.containsKey('is_full_tank')) {
      context.handle(
          _isFullTankMeta,
          isFullTank.isAcceptableOrUnknown(
              data['is_full_tank']!, _isFullTankMeta));
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
  FuelRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FuelRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      vehicleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vehicle_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}date'])!,
      fuelAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fuel_amount'])!,
      totalPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_price'])!,
      pricePerLiter: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}price_per_liter'])!,
      odometer: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}odometer'])!,
      isFullTank: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_full_tank'])!,
      isLightOn: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_light_on'])!,
      fuelType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fuel_type']),
      stationName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}station_name']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FuelRecordsTable createAlias(String alias) {
    return $FuelRecordsTable(attachedDatabase, alias);
  }
}

class FuelRecord extends DataClass implements Insertable<FuelRecord> {
  /// 记录ID
  final int id;

  /// 关联的车辆ID
  /// references()表示这是一个外键,关联到Vehicles表的id字段
  final int vehicleId;

  /// 加油日期
  final int date;

  /// 加油量(升)
  final double fuelAmount;

  /// 总金额(元)
  final double totalPrice;

  /// 单价(元/升)
  final double pricePerLiter;

  /// 当前里程数(公里)
  final double odometer;

  /// 是否加满油
  final bool isFullTank;

  /// 是否油灯亮了（亮灯法计算油耗）
  final bool isLightOn;

  /// 油品类型(92#/95#/98#/0#柴油等)
  final String? fuelType;

  /// 加油站名称
  final String? stationName;

  /// 备注
  final String? notes;

  /// 创建时间
  final int createdAt;
  const FuelRecord(
      {required this.id,
      required this.vehicleId,
      required this.date,
      required this.fuelAmount,
      required this.totalPrice,
      required this.pricePerLiter,
      required this.odometer,
      required this.isFullTank,
      required this.isLightOn,
      this.fuelType,
      this.stationName,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['date'] = Variable<int>(date);
    map['fuel_amount'] = Variable<double>(fuelAmount);
    map['total_price'] = Variable<double>(totalPrice);
    map['price_per_liter'] = Variable<double>(pricePerLiter);
    map['odometer'] = Variable<double>(odometer);
    map['is_full_tank'] = Variable<bool>(isFullTank);
    map['is_light_on'] = Variable<bool>(isLightOn);
    if (!nullToAbsent || fuelType != null) {
      map['fuel_type'] = Variable<String>(fuelType);
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

  FuelRecordsCompanion toCompanion(bool nullToAbsent) {
    return FuelRecordsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      date: Value(date),
      fuelAmount: Value(fuelAmount),
      totalPrice: Value(totalPrice),
      pricePerLiter: Value(pricePerLiter),
      odometer: Value(odometer),
      isFullTank: Value(isFullTank),
      isLightOn: Value(isLightOn),
      fuelType: fuelType == null && nullToAbsent
          ? const Value.absent()
          : Value(fuelType),
      stationName: stationName == null && nullToAbsent
          ? const Value.absent()
          : Value(stationName),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory FuelRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FuelRecord(
      id: serializer.fromJson<int>(json['id']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      date: serializer.fromJson<int>(json['date']),
      fuelAmount: serializer.fromJson<double>(json['fuelAmount']),
      totalPrice: serializer.fromJson<double>(json['totalPrice']),
      pricePerLiter: serializer.fromJson<double>(json['pricePerLiter']),
      odometer: serializer.fromJson<double>(json['odometer']),
      isFullTank: serializer.fromJson<bool>(json['isFullTank']),
      isLightOn: serializer.fromJson<bool>(json['isLightOn']),
      fuelType: serializer.fromJson<String?>(json['fuelType']),
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
      'date': serializer.toJson<int>(date),
      'fuelAmount': serializer.toJson<double>(fuelAmount),
      'totalPrice': serializer.toJson<double>(totalPrice),
      'pricePerLiter': serializer.toJson<double>(pricePerLiter),
      'odometer': serializer.toJson<double>(odometer),
      'isFullTank': serializer.toJson<bool>(isFullTank),
      'isLightOn': serializer.toJson<bool>(isLightOn),
      'fuelType': serializer.toJson<String?>(fuelType),
      'stationName': serializer.toJson<String?>(stationName),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  FuelRecord copyWith(
          {int? id,
          int? vehicleId,
          int? date,
          double? fuelAmount,
          double? totalPrice,
          double? pricePerLiter,
          double? odometer,
          bool? isFullTank,
          bool? isLightOn,
          Value<String?> fuelType = const Value.absent(),
          Value<String?> stationName = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          int? createdAt}) =>
      FuelRecord(
        id: id ?? this.id,
        vehicleId: vehicleId ?? this.vehicleId,
        date: date ?? this.date,
        fuelAmount: fuelAmount ?? this.fuelAmount,
        totalPrice: totalPrice ?? this.totalPrice,
        pricePerLiter: pricePerLiter ?? this.pricePerLiter,
        odometer: odometer ?? this.odometer,
        isFullTank: isFullTank ?? this.isFullTank,
        isLightOn: isLightOn ?? this.isLightOn,
        fuelType: fuelType.present ? fuelType.value : this.fuelType,
        stationName: stationName.present ? stationName.value : this.stationName,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  FuelRecord copyWithCompanion(FuelRecordsCompanion data) {
    return FuelRecord(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      date: data.date.present ? data.date.value : this.date,
      fuelAmount:
          data.fuelAmount.present ? data.fuelAmount.value : this.fuelAmount,
      totalPrice:
          data.totalPrice.present ? data.totalPrice.value : this.totalPrice,
      pricePerLiter: data.pricePerLiter.present
          ? data.pricePerLiter.value
          : this.pricePerLiter,
      odometer: data.odometer.present ? data.odometer.value : this.odometer,
      isFullTank:
          data.isFullTank.present ? data.isFullTank.value : this.isFullTank,
      isLightOn: data.isLightOn.present ? data.isLightOn.value : this.isLightOn,
      fuelType: data.fuelType.present ? data.fuelType.value : this.fuelType,
      stationName:
          data.stationName.present ? data.stationName.value : this.stationName,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FuelRecord(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('date: $date, ')
          ..write('fuelAmount: $fuelAmount, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('pricePerLiter: $pricePerLiter, ')
          ..write('odometer: $odometer, ')
          ..write('isFullTank: $isFullTank, ')
          ..write('isLightOn: $isLightOn, ')
          ..write('fuelType: $fuelType, ')
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
      date,
      fuelAmount,
      totalPrice,
      pricePerLiter,
      odometer,
      isFullTank,
      isLightOn,
      fuelType,
      stationName,
      notes,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FuelRecord &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.date == this.date &&
          other.fuelAmount == this.fuelAmount &&
          other.totalPrice == this.totalPrice &&
          other.pricePerLiter == this.pricePerLiter &&
          other.odometer == this.odometer &&
          other.isFullTank == this.isFullTank &&
          other.isLightOn == this.isLightOn &&
          other.fuelType == this.fuelType &&
          other.stationName == this.stationName &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class FuelRecordsCompanion extends UpdateCompanion<FuelRecord> {
  final Value<int> id;
  final Value<int> vehicleId;
  final Value<int> date;
  final Value<double> fuelAmount;
  final Value<double> totalPrice;
  final Value<double> pricePerLiter;
  final Value<double> odometer;
  final Value<bool> isFullTank;
  final Value<bool> isLightOn;
  final Value<String?> fuelType;
  final Value<String?> stationName;
  final Value<String?> notes;
  final Value<int> createdAt;
  const FuelRecordsCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.date = const Value.absent(),
    this.fuelAmount = const Value.absent(),
    this.totalPrice = const Value.absent(),
    this.pricePerLiter = const Value.absent(),
    this.odometer = const Value.absent(),
    this.isFullTank = const Value.absent(),
    this.isLightOn = const Value.absent(),
    this.fuelType = const Value.absent(),
    this.stationName = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FuelRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int vehicleId,
    required int date,
    required double fuelAmount,
    required double totalPrice,
    required double pricePerLiter,
    required double odometer,
    this.isFullTank = const Value.absent(),
    this.isLightOn = const Value.absent(),
    this.fuelType = const Value.absent(),
    this.stationName = const Value.absent(),
    this.notes = const Value.absent(),
    required int createdAt,
  })  : vehicleId = Value(vehicleId),
        date = Value(date),
        fuelAmount = Value(fuelAmount),
        totalPrice = Value(totalPrice),
        pricePerLiter = Value(pricePerLiter),
        odometer = Value(odometer),
        createdAt = Value(createdAt);
  static Insertable<FuelRecord> custom({
    Expression<int>? id,
    Expression<int>? vehicleId,
    Expression<int>? date,
    Expression<double>? fuelAmount,
    Expression<double>? totalPrice,
    Expression<double>? pricePerLiter,
    Expression<double>? odometer,
    Expression<bool>? isFullTank,
    Expression<bool>? isLightOn,
    Expression<String>? fuelType,
    Expression<String>? stationName,
    Expression<String>? notes,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (date != null) 'date': date,
      if (fuelAmount != null) 'fuel_amount': fuelAmount,
      if (totalPrice != null) 'total_price': totalPrice,
      if (pricePerLiter != null) 'price_per_liter': pricePerLiter,
      if (odometer != null) 'odometer': odometer,
      if (isFullTank != null) 'is_full_tank': isFullTank,
      if (isLightOn != null) 'is_light_on': isLightOn,
      if (fuelType != null) 'fuel_type': fuelType,
      if (stationName != null) 'station_name': stationName,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FuelRecordsCompanion copyWith(
      {Value<int>? id,
      Value<int>? vehicleId,
      Value<int>? date,
      Value<double>? fuelAmount,
      Value<double>? totalPrice,
      Value<double>? pricePerLiter,
      Value<double>? odometer,
      Value<bool>? isFullTank,
      Value<bool>? isLightOn,
      Value<String?>? fuelType,
      Value<String?>? stationName,
      Value<String?>? notes,
      Value<int>? createdAt}) {
    return FuelRecordsCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      fuelAmount: fuelAmount ?? this.fuelAmount,
      totalPrice: totalPrice ?? this.totalPrice,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      odometer: odometer ?? this.odometer,
      isFullTank: isFullTank ?? this.isFullTank,
      isLightOn: isLightOn ?? this.isLightOn,
      fuelType: fuelType ?? this.fuelType,
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
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (fuelAmount.present) {
      map['fuel_amount'] = Variable<double>(fuelAmount.value);
    }
    if (totalPrice.present) {
      map['total_price'] = Variable<double>(totalPrice.value);
    }
    if (pricePerLiter.present) {
      map['price_per_liter'] = Variable<double>(pricePerLiter.value);
    }
    if (odometer.present) {
      map['odometer'] = Variable<double>(odometer.value);
    }
    if (isFullTank.present) {
      map['is_full_tank'] = Variable<bool>(isFullTank.value);
    }
    if (isLightOn.present) {
      map['is_light_on'] = Variable<bool>(isLightOn.value);
    }
    if (fuelType.present) {
      map['fuel_type'] = Variable<String>(fuelType.value);
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
    return (StringBuffer('FuelRecordsCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('date: $date, ')
          ..write('fuelAmount: $fuelAmount, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('pricePerLiter: $pricePerLiter, ')
          ..write('odometer: $odometer, ')
          ..write('isFullTank: $isFullTank, ')
          ..write('isLightOn: $isLightOn, ')
          ..write('fuelType: $fuelType, ')
          ..write('stationName: $stationName, ')
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
  late final $FuelRecordsTable fuelRecords = $FuelRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [vehicles, fuelRecords];
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
  Value<int> createdAt,
  Value<int> updatedAt,
});

final class $$VehiclesTableReferences
    extends BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle> {
  $$VehiclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FuelRecordsTable, List<FuelRecord>>
      _fuelRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.fuelRecords,
          aliasName:
              $_aliasNameGenerator(db.vehicles.id, db.fuelRecords.vehicleId));

  $$FuelRecordsTableProcessedTableManager get fuelRecordsRefs {
    final manager = $$FuelRecordsTableTableManager($_db, $_db.fuelRecords)
        .filter((f) => f.vehicleId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_fuelRecordsRefsTable($_db));
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

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> fuelRecordsRefs(
      Expression<bool> Function($$FuelRecordsTableFilterComposer f) f) {
    final $$FuelRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.fuelRecords,
        getReferencedColumn: (t) => t.vehicleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FuelRecordsTableFilterComposer(
              $db: $db,
              $table: $db.fuelRecords,
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

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> fuelRecordsRefs<T extends Object>(
      Expression<T> Function($$FuelRecordsTableAnnotationComposer a) f) {
    final $$FuelRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.fuelRecords,
        getReferencedColumn: (t) => t.vehicleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FuelRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.fuelRecords,
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
    PrefetchHooks Function({bool fuelRecordsRefs})> {
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
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$VehiclesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({fuelRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (fuelRecordsRefs) db.fuelRecords],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (fuelRecordsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$VehiclesTableReferences._fuelRecordsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VehiclesTableReferences(db, table, p0)
                                .fuelRecordsRefs,
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
    PrefetchHooks Function({bool fuelRecordsRefs})>;
typedef $$FuelRecordsTableCreateCompanionBuilder = FuelRecordsCompanion
    Function({
  Value<int> id,
  required int vehicleId,
  required int date,
  required double fuelAmount,
  required double totalPrice,
  required double pricePerLiter,
  required double odometer,
  Value<bool> isFullTank,
  Value<bool> isLightOn,
  Value<String?> fuelType,
  Value<String?> stationName,
  Value<String?> notes,
  required int createdAt,
});
typedef $$FuelRecordsTableUpdateCompanionBuilder = FuelRecordsCompanion
    Function({
  Value<int> id,
  Value<int> vehicleId,
  Value<int> date,
  Value<double> fuelAmount,
  Value<double> totalPrice,
  Value<double> pricePerLiter,
  Value<double> odometer,
  Value<bool> isFullTank,
  Value<bool> isLightOn,
  Value<String?> fuelType,
  Value<String?> stationName,
  Value<String?> notes,
  Value<int> createdAt,
});

final class $$FuelRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $FuelRecordsTable, FuelRecord> {
  $$FuelRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias(
          $_aliasNameGenerator(db.fuelRecords.vehicleId, db.vehicles.id));

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

class $$FuelRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $FuelRecordsTable> {
  $$FuelRecordsTableFilterComposer({
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

  ColumnFilters<double> get fuelAmount => $composableBuilder(
      column: $table.fuelAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pricePerLiter => $composableBuilder(
      column: $table.pricePerLiter, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get odometer => $composableBuilder(
      column: $table.odometer, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFullTank => $composableBuilder(
      column: $table.isFullTank, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isLightOn => $composableBuilder(
      column: $table.isLightOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fuelType => $composableBuilder(
      column: $table.fuelType, builder: (column) => ColumnFilters(column));

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

class $$FuelRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $FuelRecordsTable> {
  $$FuelRecordsTableOrderingComposer({
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

  ColumnOrderings<double> get fuelAmount => $composableBuilder(
      column: $table.fuelAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pricePerLiter => $composableBuilder(
      column: $table.pricePerLiter,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get odometer => $composableBuilder(
      column: $table.odometer, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFullTank => $composableBuilder(
      column: $table.isFullTank, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isLightOn => $composableBuilder(
      column: $table.isLightOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fuelType => $composableBuilder(
      column: $table.fuelType, builder: (column) => ColumnOrderings(column));

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

class $$FuelRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FuelRecordsTable> {
  $$FuelRecordsTableAnnotationComposer({
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

  GeneratedColumn<double> get fuelAmount => $composableBuilder(
      column: $table.fuelAmount, builder: (column) => column);

  GeneratedColumn<double> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => column);

  GeneratedColumn<double> get pricePerLiter => $composableBuilder(
      column: $table.pricePerLiter, builder: (column) => column);

  GeneratedColumn<double> get odometer =>
      $composableBuilder(column: $table.odometer, builder: (column) => column);

  GeneratedColumn<bool> get isFullTank => $composableBuilder(
      column: $table.isFullTank, builder: (column) => column);

  GeneratedColumn<bool> get isLightOn =>
      $composableBuilder(column: $table.isLightOn, builder: (column) => column);

  GeneratedColumn<String> get fuelType =>
      $composableBuilder(column: $table.fuelType, builder: (column) => column);

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

class $$FuelRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FuelRecordsTable,
    FuelRecord,
    $$FuelRecordsTableFilterComposer,
    $$FuelRecordsTableOrderingComposer,
    $$FuelRecordsTableAnnotationComposer,
    $$FuelRecordsTableCreateCompanionBuilder,
    $$FuelRecordsTableUpdateCompanionBuilder,
    (FuelRecord, $$FuelRecordsTableReferences),
    FuelRecord,
    PrefetchHooks Function({bool vehicleId})> {
  $$FuelRecordsTableTableManager(_$AppDatabase db, $FuelRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FuelRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FuelRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FuelRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> vehicleId = const Value.absent(),
            Value<int> date = const Value.absent(),
            Value<double> fuelAmount = const Value.absent(),
            Value<double> totalPrice = const Value.absent(),
            Value<double> pricePerLiter = const Value.absent(),
            Value<double> odometer = const Value.absent(),
            Value<bool> isFullTank = const Value.absent(),
            Value<bool> isLightOn = const Value.absent(),
            Value<String?> fuelType = const Value.absent(),
            Value<String?> stationName = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              FuelRecordsCompanion(
            id: id,
            vehicleId: vehicleId,
            date: date,
            fuelAmount: fuelAmount,
            totalPrice: totalPrice,
            pricePerLiter: pricePerLiter,
            odometer: odometer,
            isFullTank: isFullTank,
            isLightOn: isLightOn,
            fuelType: fuelType,
            stationName: stationName,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int vehicleId,
            required int date,
            required double fuelAmount,
            required double totalPrice,
            required double pricePerLiter,
            required double odometer,
            Value<bool> isFullTank = const Value.absent(),
            Value<bool> isLightOn = const Value.absent(),
            Value<String?> fuelType = const Value.absent(),
            Value<String?> stationName = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required int createdAt,
          }) =>
              FuelRecordsCompanion.insert(
            id: id,
            vehicleId: vehicleId,
            date: date,
            fuelAmount: fuelAmount,
            totalPrice: totalPrice,
            pricePerLiter: pricePerLiter,
            odometer: odometer,
            isFullTank: isFullTank,
            isLightOn: isLightOn,
            fuelType: fuelType,
            stationName: stationName,
            notes: notes,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$FuelRecordsTableReferences(db, table, e)
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
                        $$FuelRecordsTableReferences._vehicleIdTable(db),
                    referencedColumn:
                        $$FuelRecordsTableReferences._vehicleIdTable(db).id,
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

typedef $$FuelRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FuelRecordsTable,
    FuelRecord,
    $$FuelRecordsTableFilterComposer,
    $$FuelRecordsTableOrderingComposer,
    $$FuelRecordsTableAnnotationComposer,
    $$FuelRecordsTableCreateCompanionBuilder,
    $$FuelRecordsTableUpdateCompanionBuilder,
    (FuelRecord, $$FuelRecordsTableReferences),
    FuelRecord,
    PrefetchHooks Function({bool vehicleId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$FuelRecordsTableTableManager get fuelRecords =>
      $$FuelRecordsTableTableManager(_db, _db.fuelRecords);
}
