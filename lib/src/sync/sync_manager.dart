import 'dart:convert';
import 'dart:io';

import 'package:intl_utils/src/sync/append_key.dart';
import 'package:intl_utils/src/sync/sort_key.dart';
import 'package:path/path.dart';

import '../config/pubspec_config.dart';
import '../constants/constants.dart';
import '../utils/file_utils.dart';

/// The generator of localization files.
class SyncManager {
  late String _arbDir;
  late SyncConfig _syncConfig;
  Map<String, Map<String, dynamic>> _arbs = {};

  /// Creates a new generator with configuration from the 'pubspec.yaml' file.
  SyncManager() {
    var pubspecConfig = PubspecConfig();

    _syncConfig = pubspecConfig.syncConfig ?? SyncConfig.fromConfig(null);

    _arbDir = pubspecConfig.arbDir ?? defaultArbDir;
  }

  /// Generates localization files.
  Future<void> generateAsync() async {
    _getMainArbs();
    _findPackages();
    _writeMainArbs();
  }

  _getMainArbs() {
    for (var file
        in Directory(join(getRootDirectoryPath(), _arbDir)).listSync()) {
      if (file is File && file.path.endsWith('.arb')) {
        _processArb(file);
      }
    }
  }

  _findPackages() {
    var pkgConfig = json.decode(
        File(join(getRootDirectoryPath(), '.dart_tool/package_config.json'))
            .readAsStringSync());
    for (var package in pkgConfig['packages']) {
      var syncPackage = _syncConfig.packages[package['name']];
      if (syncPackage != null) {
        _generateArb(package['name'],
            _getPackageDirectory(join(package['rootUri'], syncPackage.path)));
      }
    }
  }

  Directory _getPackageDirectory(String uriOrPath) {
    if (uriOrPath.startsWith('file:')) {
      return Directory.fromUri(Uri.parse(uriOrPath));
    }
    if (uriOrPath.startsWith('..')) {
      return Directory(join('.dart_tool', uriOrPath));
    }
    return Directory(uriOrPath);
  }

  _generateArb(String name, Directory arbDir) {
    for (var file in arbDir.listSync()) {
      if (file is File && file.path.endsWith('.arb')) {
        _processArb(file);
      }
    }
  }

  _processArb(File arbFile) {
    var name = basename(arbFile.path);
    if (_arbs[name] == null) {
      _arbs[name] = {};
    }
    _arbs[name] =
        appendNewKeys(_arbs[name]!, json.decode(arbFile.readAsStringSync()));
  }

  _writeMainArbs() {
    var basePath = join(getRootDirectoryPath(), _arbDir);
    for (var arb in _arbs.entries) {
      File(join(basePath, arb.key)).writeAsStringSync(sortARB(arb.value));
    }
  }
}
