// SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
// SPDX-License-Identifier: AGPL-3.0-or-later

import assert from 'node:assert/strict';
import test from 'node:test';

import { readConfig } from '../src/config.js';

void test('uses safe standalone defaults', () => {
  assert.deepEqual(readConfig({}), {
    host: '127.0.0.1',
    nodeEnv: 'development',
    port: 3001,
  });
});

void test('accepts an explicit valid configuration', () => {
  assert.deepEqual(readConfig({ HOST: '0.0.0.0', NODE_ENV: 'test', PORT: '4100' }), {
    host: '0.0.0.0',
    nodeEnv: 'test',
    port: 4100,
  });
});

void test('rejects invalid environment and port values', () => {
  assert.throws(() => readConfig({ NODE_ENV: 'demo' }), /NODE_ENV/);
  for (const port of ['0', '65536', '1.5', 'not-a-port']) {
    assert.throws(() => readConfig({ PORT: port }), /PORT/);
  }
});
