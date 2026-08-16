// SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
// SPDX-License-Identifier: AGPL-3.0-or-later

import assert from 'node:assert/strict';
import { once } from 'node:events';
import type { AddressInfo } from 'node:net';
import test from 'node:test';

import { createServer } from '../src/server.js';

void test('returns an explicit unavailable response without another service', async (context) => {
  const server = createServer();
  server.listen(0, '127.0.0.1');
  await once(server, 'listening');
  context.after(() => server.close());

  const address = server.address() as AddressInfo;
  const response = await fetch(`http://127.0.0.1:${String(address.port)}/anything`);

  assert.equal(response.status, 503);
  assert.equal(response.headers.get('cache-control'), 'no-store');
  assert.equal(response.headers.get('x-content-type-options'), 'nosniff');
  assert.deepEqual(await response.json(), {
    error: {
      code: 'FEATURE_UNAVAILABLE',
      message: 'The backend feature set is not available in this migration phase.',
    },
  });
});
