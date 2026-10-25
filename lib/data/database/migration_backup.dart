// 迁移前自动备份（规格 §7.1 step 0 / §7.1b）
//
// 为什么必须在「打开数据库连接之前」做：
//   连接打开后可能处于事务中；而且一旦将来启用 WAL，主 .db 文件不含最新已提交数据
//   （数据还在 -wal 里），此时复制出来的备份是旧快照 —— 只有真需要恢复那天才会发现。
//
// 做法：只读地读一次 PRAGMA user_version，判断库是否还是旧版（< 4），是则把
//   .db / .db-wal / .db-shm 三件套一起复制成 *.pre-v4.bak*。

import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;

import 'package:sqlite3/sqlite3.dart';

import 'app_database.dart' show getDatabaseFile;

/// 当前 schema 版本（与 AppDatabase.schemaVersion 保持一致）
const int kCurrentSchemaVersion = 4;

/// 数据库文件名
const String kDbFileName = 'zhiji_oil.db';

/// 备份后缀
const String kPreMigrationBackupSuffix = '.pre-v4.bak';

/// 如果数据库还是旧版本，就在打开连接之前复制一份备份。
///
/// 返回备份文件路径（没做备份时返回 null）。
/// 任何异常都被吞掉：**备份失败不能阻止 App 启动**，否则用户直接打不开。
Future<String?> ensurePreMigrationBackup() async {
  try {
    final dbFile = await getDatabaseFile();

    // 全新安装：没有库文件，不需要备份
    if (!await dbFile.exists()) return null;

    final version = _readUserVersion(dbFile.path);
    if (version == null || version >= kCurrentSchemaVersion) return null;

    final base = dbFile.path;
    final backupMain = '$base$kPreMigrationBackupSuffix';

    // 关键：备份只做一次。
    // 若迁移中途失败，库会停在"半迁移、user_version 仍为 3"的状态；
    // 下次启动若不判断就直接复制，会把唯一的原始好快照覆盖成半成品。
    if (await File(backupMain).exists()) {
      return backupMain; // 已有备份，保留第一份，不再覆盖
    }

    for (final suffix in ['', '-wal', '-shm']) {
      final src = File('$base$suffix');
      if (await src.exists()) {
        await src.copy('$backupMain$suffix');
      }
    }
    return backupMain;
  } catch (_) {
    // 备份只是保险，失败不阻断启动
    return null;
  }
}

/// 只读地读 user_version
int? _readUserVersion(String path) {
  Database? db;
  try {
    db = sqlite3.open(path, mode: OpenMode.readOnly);
    final rs = db.select('PRAGMA user_version');
    if (rs.isEmpty) return 0;
    final v = rs.first.values.first;
    return v is int ? v : int.tryParse('$v') ?? 0;
  } catch (e) {
    // 读不到版本 = 没做备份。留一行日志，避免"静默不备份"
    // （例如将来启用 WAL 后，只读打开可能需要 -shm 可写）
    debugPrint('[迁移备份] 读取 user_version 失败，跳过备份: $e');
    return null;
  } finally {
    db?.dispose();
  }
}
