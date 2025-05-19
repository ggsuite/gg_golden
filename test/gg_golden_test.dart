// @license
// Copyright (c) 2019 - 2025 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_golden/gg_golden.dart';
import 'package:test/test.dart';

void main() {
  group('GgGolden()', () {
    group('foo()', () {
      test('should return foo', () async {
        const ggGolden = GgGolden();
        expect(ggGolden.foo(), 'foo');
      });
    });
  });
}
