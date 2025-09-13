// @license
// Copyright (c) 2019 - 2025 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:io';

import 'package:gg_golden/gg_golden.dart';
import 'package:test/test.dart';

void main() {
  group('expectGolden(fileName, expected, updateGoldensEnabled)', () {
    group('with updateGolden = true', () {
      test('creates a golden file in goldens()', () async {
        // Golden file does not exist
        final goldenFile = File('test/goldens/test/test.golden.json');
        if (await goldenFile.exists()) {
          await goldenFile.delete();
        }
        expect(await goldenFile.exists(), false);

        // Create golden
        final json = {'foo': 'true'};
        try {
          await expectGolden('test/test.golden.json', json, updateGolden: true);
        } catch (e) {
          expect(e, isNotNull);
        }

        // Golden file exists
        expect(await goldenFile.exists(), true);

        // Next golden file should pass
        await expectGolden('test/test.golden.json', json, updateGolden: false);

        // Testing against a modified golden should fail
        var message = '';
        try {
          final modifiedJson = {'foo': 'juhu'};

          await expectGolden(
            'test/test.golden.json',
            modifiedJson,
            updateGolden: false,
          );
        } catch (e) {
          expect(e, isA<TestFailure>());
          message = (e as TestFailure).message!;
        }

        expect(message.split('\n'), [
          'Golden file does not match data.',
          'Set "updateGoldens" to "true" and try again.',
          'Review "test/goldens/test/test.golden.json" afterwards.',
        ]);
      });
    });

    group('with updateGoldens = false', () {
      test('does not update golden file', () async {
        // Golden file does not exist
        final goldenFile = File('test/goldens/test/test.golden.json');
        if (await goldenFile.exists()) {
          await goldenFile.delete();
        }
        expect(await goldenFile.exists(), false);

        // Create golden
        final json = {'foo': 'true'};
        var message = '';
        try {
          await expectGolden('test/test.golden.json', json, updateGolden: true);
        } catch (e) {
          expect(e, isA<TestFailure>());
          message = (e as TestFailure).message!;
        }
        expect(message.trim().split('\n'), [
          'Please set "updateGolden" back to "false".',
          'Golden file was updated successful.',
        ]);

        // Golden file exists
        expect(await goldenFile.exists(), true);

        // Next golden file should pass
        await expectGolden('test/test.golden.json', json, updateGolden: false);

        // Try to update with a modified golden and updateGoldens = false
        // It fails, because updateGoldens is false

        try {
          final modifiedJson = {'foo': 'juhu'};

          await expectGolden(
            'test/test.golden.json',
            modifiedJson,
            updateGoldensEnabled: false,
            updateGolden: true,
          );
        } catch (e) {
          expect(e, isA<TestFailure>());
          message = (e as TestFailure).message!;
        }

        expect(message.split('\n'), [
          "Expected: {'foo': 'true'}",
          "  Actual: {'foo': 'juhu'}",
          "   Which: at location ['foo'] is 'juhu' instead of 'true'",
          '',
        ]);
      });
    });
  });
}
