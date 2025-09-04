// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:gg_golden/src/tools.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  group('Tools', () {
    group('projectRoot(path)', () {
      group('returns the project root of the dart project on path', () {
        test('with path being a directory', () async {
          final cwd = Directory.current.path;
          expect(await projectRoot('$cwd/test/'), cwd);
        });

        test('with path being a file', () async {
          final cwd = Directory.current.path;
          expect(await projectRoot('$cwd/test/tools_test.dart'), cwd);
        });
      });

      test('throws, when no pubspec.yaml is found', () async {
        final tmpDir = Directory.systemTemp.path;
        var message = <String>[];
        try {
          await projectRoot(tmpDir);
        } catch (e) {
          message = (e as dynamic).message.toString().split('\n');
        }

        expect(message, ['No pubspec.yaml found.']);
      });
    });

    group('goldenDir(stackTrace)', () {
      test('returns the goldens dir for the current test file', () async {
        expect(
          await goldenDir(StackTrace.current.toString()),
          endsWith('test/goldens/tools'),
        );
      });

      group('throws', () {
        test('when stack trace does not contain main.', () async {
          var message = <String>[];
          try {
            await goldenDir(['#0 a', '#1 b'].join('\n'));
          } catch (e) {
            message = (e as dynamic).message.toString().split('\n');
          }

          expect(message, [
            'write_golden: Could not find "main." in call stack.',
            '  Please submit an error report to ',
            '  https://github.com/ggsuite/gg_golden/issues',
          ]);
        });

        test('when stack trace does not contain file://', () async {
          var message = <String>[];
          try {
            await goldenDir(['#0 a', '#1  main.'].join('\n'));
          } catch (e) {
            message = (e as dynamic).message.toString().split('\n');
          }

          expect(message, [
            'write_golden: Could not find file:// in call stack.',
            '  Please submit an error report to ',
            '  https://github.com/ggsuite/gg_golden/issues',
          ]);
        });

        test('when main file is not a test', () async {
          var message = <String>[];
          try {
            await goldenDir(
              ['#0 a', '#1  main. file:///notest.dart'].join('\n'),
            );
          } catch (e) {
            message = (e as dynamic).message.toString().split('\n');
          }

          expect(message, [
            'writeGolden(...) must only be called from test files',
          ]);
        });

        test('when main file is not in test directory', () async {
          var message = <String>[];

          final testDir = Directory(
            join(Directory.systemTemp.path, 'tools_test'),
          );
          await testDir.create(recursive: false);
          await File('${testDir.path}/pubspec.yaml').writeAsString('#');

          final filePath = '${testDir.path}/some_test.dart';

          try {
            await goldenDir(['#0 a', '#1  main. file://$filePath'].join('\n'));
          } catch (e) {
            message = (e as dynamic).message.toString().split('\n');
          }

          expect(message, [
            'writeGolden(...) must only be called from files within test',
          ]);

          await testDir.delete(recursive: true);
        });
      });
    });
  });
}
