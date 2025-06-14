// @license
// Copyright (c) 2019 - 2025 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// If this is set to true, the golden files will be updated.
bool updateGoldensFromEnv() {
  return Platform.environment['UPDATE_GOLDENS'] == 'true';
}

/// Updates the golden file with the given content and compares it.
Future<void> expectGolden(
  String fileName,
  dynamic expected, {
  required bool updateGolden,
  bool updateGoldensEnabled = true,
}) async {
  final goldensDir = p.join(Directory.current.path, 'test', 'goldens');
  final filePath = p.join(goldensDir, fileName);
  final filePathRelative = p.relative(filePath, from: Directory.current.path);

  // Stringify json
  final expectedStr = const JsonEncoder.withIndent('  ').convert(expected);

  // Write golden file if update is enabled
  if (updateGoldensEnabled && (updateGolden || updateGoldensFromEnv())) {
    await Directory(p.dirname(filePath)).create(recursive: true);
    await File(filePath).writeAsString(expectedStr);
    fail(
      [
        'Golden file was updated successful.',
        'Please set "updateGolden" back to "false" and try again.',
      ].join('\n'),
    );
  }

  // Read golden file
  bool needsGoldenUpdate = true;
  dynamic golden;
  try {
    final goldenStr = await File(filePath).readAsString();
    golden = jsonDecode(goldenStr);
    needsGoldenUpdate = false;
  } catch (_) {
    needsGoldenUpdate = true;
  }

  if (updateGoldensEnabled) {
    needsGoldenUpdate = !const DeepCollectionEquality().equals(
      expected,
      golden,
    );
    if (needsGoldenUpdate) {
      fail(
        [
          'Golden file does not match data.',
          'Set "updateGoldens" to "true" and try again.',
          'Review "$filePathRelative" afterwards.',
        ].join('\n'),
      );
    }
  } else {
    expect(needsGoldenUpdate, isFalse);
    expect(expected, equals(golden));
  }
}
