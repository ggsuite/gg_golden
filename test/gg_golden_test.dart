// @license
// Copyright (c) 2019 - 2025 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:gg_golden/gg_golden.dart';
import 'package:test/test.dart';

void main() {
  group('expectGolden(fileName, expected, updateGoldensEnabled)', () {
    final goldensDir = Directory('test/goldens');

    Future<void> recreateGoldensDir() async {
      // Delete test/goldens dir when existing
      if (await goldensDir.exists()) {
        await goldensDir.delete(recursive: true);
      }
      await goldensDir.create(recursive: true);
    }

    group('with updateGoldens = true', () {
      test('creates a golden file in goldens()', () async {
        await recreateGoldensDir();

        // Golden file does not exst
        final goldenFile = File('test/goldens/test/test.golden.json');
        expect(await goldenFile.exists(), false);

        // Create golden
        final json = {'foo': 'true'};
        await expectGolden(
          'test/test.golden.json',
          json,
          mockPlatformUpdateGoldens: true,
        );

        // Golden file exists
        expect(await goldenFile.exists(), true);

        // Next golden file should pass
        await expectGolden(
          'test/test.golden.json',
          json,
        );

        // Testing against a modified golden should fail
        var message = '';
        try {
          final modifiedJson = {'foo': 'juhu'};

          await expectGolden(
            'test/test.golden.json',
            modifiedJson,
          );
        } catch (e) {
          expect(e, isA<TestFailure>());
          message = (e as TestFailure).message!;
        }

        expect(
          message,
          'Run "dart run update_goldens" and review "test/goldens/test/test.golden.json".',
        );
      });
    });

    group('with updateGoldens = false', () {
      test('does not update golden file', () async {
        await recreateGoldensDir();

        // Golden file does not exst
        final goldenFile = File('test/goldens/test/test.golden.json');
        expect(await goldenFile.exists(), false);

        // Create golden
        final json = {'foo': 'true'};
        await expectGolden(
          'test/test.golden.json',
          json,
          mockPlatformUpdateGoldens: true,
        );

        // Golden file exists
        expect(await goldenFile.exists(), true);

        // Next golden file should pass
        await expectGolden(
          'test/test.golden.json',
          json,
        );

        // Try to update with a modified golden and updateGoldens = false
        // It fails, because updateGoldens is false

        var message = '';
        try {
          final modifiedJson = {'foo': 'juhu'};

          await expectGolden(
            'test/test.golden.json',
            modifiedJson,
            updateGoldensEnabled: false,
            mockPlatformUpdateGoldens: true,
          );
        } catch (e) {
          expect(e, isA<TestFailure>());
          message = (e as TestFailure).message!;
        }

        expect(
          message.split('\n'),
          [
            "Expected: {'foo': 'true'}",
            "  Actual: {'foo': 'juhu'}",
            "   Which: at location ['foo'] is 'juhu' instead of 'true'",
            '',
          ],
        );
      });
    });
  });
}
