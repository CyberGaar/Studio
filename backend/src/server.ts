// SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
// SPDX-License-Identifier: AGPL-3.0-or-later

import { createServer as createHttpServer, type Server } from 'node:http';

const unavailableBody = JSON.stringify({
  error: {
    code: 'FEATURE_UNAVAILABLE',
    message: 'The backend feature set is not available in this migration phase.',
  },
});

export function createServer(): Server {
  return createHttpServer((request, response) => {
    response.writeHead(503, {
      'cache-control': 'no-store',
      'content-length': Buffer.byteLength(unavailableBody),
      'content-type': 'application/json; charset=utf-8',
      'x-content-type-options': 'nosniff',
    });
    response.end(unavailableBody);
  });
}
