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
bool shouldUpdateGoldens() {
  return Platform.environment['UPDATE_GOLDENS'] == 'true';
}

/// Updates the golden file with the given content and compares it.
Future<void> expectGolden(
  String fileName,
  dynamic expected, {
  bool updateGoldensEnabled = true,
  bool mockPlatformUpdateGoldens = false,
}) async {
  final goldensDir = p.join(Directory.current.path, 'test', 'goldens');
  final filePath = p.join(goldensDir, fileName);
  final filePathRelative = p.relative(filePath, from: Directory.current.path);

  // Stringify json
  final expectedStr = const JsonEncoder.withIndent('  ').convert(expected);

  // Write golden file if update is enabled
  if (updateGoldensEnabled &&
      (mockPlatformUpdateGoldens || shouldUpdateGoldens())) {
    await Directory(p.dirname(filePath)).create(recursive: true);
    await File(filePath).writeAsString(expectedStr);
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
    needsGoldenUpdate =
        !const DeepCollectionEquality().equals(expected, golden);
    if (needsGoldenUpdate) {
      fail('Run "dart run update_goldens" and review "$filePathRelative".');
    }
  } else {
    expect(needsGoldenUpdate, isFalse);
    expect(expected, equals(golden));
  }
}
