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
/// Derives the goldens directory from a stack trace
String callerPath(String stackTrace) {
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

  // Extract the file path from the entry, handling both Windows and Linux paths
  final match = RegExp(
    r'.*file://(/|)([A-Za-z]:)?([^:]*\.dart)',
  ).firstMatch(entry);
  if (match == null) {
    _throw('Could not extract file path from call stack.');
  }
  String callerFilePath;
  if (match!.group(2) != null) {
    // Windows path
    callerFilePath = '${match.group(2)}${match.group(3)}';
  } else {
    // Unix path
    callerFilePath = '/${match.group(3)}';
  }
  callerFilePath = callerFilePath.replaceAll('\\', '/');

  return callerFilePath;
}

// .............................................................................
/// Derives the goldens directory from a stack trace
Future<String> goldenDir([String? stackTrace]) async {
  stackTrace ??= StackTrace.current.toString();
  final cp = callerPath(stackTrace);

  if (!cp.endsWith('_test.dart')) {
    throw Exception('writeGolden(...) must only be called from test files');
  }

  final root = await projectRoot(cp);
  final relativePath = relative(cp, from: root);
  if (!relativePath.startsWith(RegExp(r'test[/\\]'))) {
    throw Exception(
      'writeGolden(...) must only be called from files within test',
    );
  }

  // test/write_golden_test.dart -> write_golden
  final directory = relativePath.substring(5, relativePath.length - 10);
  final result = join(root, 'test', 'goldens', directory).replaceAll('\\', '/');

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
