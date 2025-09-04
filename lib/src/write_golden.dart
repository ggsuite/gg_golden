// @license
// Copyright (c) 2019 - 2025 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:convert';
import 'dart:io';

import 'package:gg_golden/src/tools.dart';
import 'package:path/path.dart';

// .............................................................................
/// Write golden file with json compatible data types
Future<void> writeGolden({
  required String fileName,
  required dynamic data,
  bool writeAsBytes = false,
}) async {
  if (data is! Map &&
      data is! List &&
      data is! String &&
      data is! num &&
      data is! bool &&
      data != null) {
    throw ArgumentError(
      'data must be a JSON-compatible type '
      '(Map, List, String, num, bool, or null)',
    );
  }

  final goldensDir = await goldenDir(StackTrace.current.toString());
  final filePath = join(goldensDir, fileName);

  // Stringify json
  final expectedStr = const JsonEncoder.withIndent('  ').convert(data);

  await Directory(dirname(filePath)).create(recursive: true);
  await File(filePath).writeAsString(expectedStr);
}

// .............................................................................
/// Write golden file with binary data
Future<void> writeBinaryGolden({
  required String fileName,
  required List<int> data,
  bool writeAsBytes = false,
}) async {
  final goldensDir = await goldenDir(StackTrace.current.toString());
  final filePath = join(goldensDir, fileName);

  await Directory(dirname(filePath)).create(recursive: true);
  await File(filePath).writeAsBytes(data);
}
