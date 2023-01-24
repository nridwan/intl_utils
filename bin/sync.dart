library intl_utils;

import 'package:intl_utils/src/generator/generator_exception.dart';
import 'package:intl_utils/src/sync/sync_manager.dart';
import 'package:intl_utils/src/utils/utils.dart';
import './generate.dart' as generate;

Future<void> main(List<String> args) async {
  try {
    var sync = SyncManager();
    await sync.generateAsync();
  } on GeneratorException catch (e) {
    exitWithError(e.message);
  } catch (e) {
    exitWithError('Failed to generate localization files.\n$e');
  }
  generate.main([]);
}
