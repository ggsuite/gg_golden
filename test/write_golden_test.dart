// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:gg_golden/gg_golden.dart';
import 'package:test/test.dart';

class Foo {}

void main() {
  group('writeGolden', () {
    group('writeGolden', () {
      Future<void> testGolden(
        String fileName,
        dynamic contentIn,
        dynamic contentOutExpected,
      ) async {
        await writeGolden(fileName: fileName, data: contentIn);

        final expectedPath = 'test/goldens/write_golden/$fileName';
        final file = File(expectedPath);
        final exists = await file.exists();

        expect(exists, isTrue);

        final contentOut = contentOutExpected is String
            ? await file.readAsString()
            : await file.readAsBytes();

        expect(contentOut, contentOutExpected);
      }

      test('writes json', () async {
        await testGolden('some_data.json', {
          'some': 'data',
        }, '{\n  "some": "data"\n}');
      });

      test('writes numbers', () async {
        await testGolden('numbers.json', 578, '578');
      });

      test('writes booleans', () async {
        await testGolden('numbers.json', true, 'true');
      });

      test('writes lists', () async {
        await testGolden(
          'list.json',
          [true, false, 1, 'str', 1.0],
          '[\n'
              '  true,\n'
              '  false,\n'
              '  1,\n'
              '  "str",\n'
              '  1.0\n'
              ']',
        );
      });

      test('throws on invalid format', () async {
        var message = <String>[];
        try {
          await writeGolden(fileName: 'foo.txt', data: Foo());
        } catch (e) {
          message = (e as dynamic).message.toString().split('\n');
        }

        expect(message, [
          'data must be a JSON-compatible type '
              '(Map, List, String, num, bool, or null)',
        ]);
      });
    });

    group('writeBinaryGolden', () {
      test('writes binary data', () async {
        final bytes = [0xDE, 0xAD, 0xBE, 0xEF];
        await writeBinaryGolden(fileName: 'binary.dat', data: bytes);

        const expectedPath = 'test/goldens/write_golden/binary.dat';
        final file = File(expectedPath);
        final exists = await file.exists();

        expect(exists, isTrue);

        final contentOut = await file.readAsBytes();
        expect(contentOut, bytes);
      });
    });
  });
}
