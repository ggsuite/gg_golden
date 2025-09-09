// @license
// Copyright (c) 2025 Dr. Gabriel Gatzsche
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart';

// .............................................................................
/// Returns the root of the current project
Future<String> projectRoot(String path, {int depth = 10}) async {
  // Is path directory? If not, use parent directory
  final dir = await FileSystemEntity.isFile(path)
      ? File(path).parent
      : Directory(path);

  // Iterate directory and its parent until pubspec.yaml is found
  var parent = dir;
  var restDepth = depth;
  while (parent.path != '/' && restDepth > 0) {
    final pubspec = File('${parent.path}/pubspec.yaml');
    if (await pubspec.exists()) {
      return parent.path;
    }
    parent = parent.parent;
    restDepth--;
  }

  throw Exception('No pubspec.yaml found.');
}

// .............................................................................
/// Derivces the goldens directory from a stack trace
Future<String> goldenDir(String stackTrace) async {
  final callerStackTraceEntry = stackTrace
      .toString()
      .split('\n')
      .firstWhereOrNull((e) => e.contains(' main.'));

  if ((callerStackTraceEntry == null)) {
    _throw('Could not find "main." in call stack.');
  }

  final entry = callerStackTraceEntry!;
  if (!entry.contains('file://')) {
    _throw('Could not find file:// in call stack.');
  }

  final callerFilePath = entry.split('file://')[1].split(':')[0];
  if (!callerFilePath.endsWith('_test.dart')) {
    throw Exception('writeGolden(...) must only be called from test files');
  }

  final root = await projectRoot(callerFilePath);
  final relativePath = relative(callerFilePath, from: root);
  if (!relativePath.startsWith(RegExp(r'test[/\\]'))) {
    throw Exception(
      'writeGolden(...) must only be called from files within test',
    );
  }

  // test/write_golden_test.dart -> write_golden
  final directory = relativePath.substring(5, relativePath.length - 10);
  final result = join(root, 'test', 'goldens', directory);

  return result;
}

// .............................................................................
void _throw(String error) {
  throw Exception(
    [
      'write_golden: $error',
      '  Please submit an error report to ',
      '  https://github.com/ggsuite/gg_golden/issues',
    ].join('\n'),
  );
}
