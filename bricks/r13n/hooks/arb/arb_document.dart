import 'dart:convert';
import 'dart:io';

import '../hooks.dart';

class ArbDocument {
  const ArbDocument._({
    required this.path,
    required this.values,
  });

  static const extension = '.arb';

  final String path;
  final List<ArbValue> values;

  static Future<ArbDocument> read(String path) async {
    assert(path.endsWith(extension), 'File is not a valid arb file: $path');

    final file = File(path);
    final json = await file.readAsString();
    final content = jsonDecode(json) as Map<String, dynamic>;

    final values = content.entries
        .map((e) => ArbValue(key: e.key, value: e.value as String))
        .toList();

    return ArbDocument._(path: path, values: values);
  }

  String get region {
    try {
      return values.firstWhere((value) => value.key == '@@region').value;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        const ArbMissingRegionTagException(),
        stackTrace,
      );
    }
  }

  Iterable<ArbValue> get regionalizedValues =>
      values.where((value) => !value.key.startsWith('@@'));
}
