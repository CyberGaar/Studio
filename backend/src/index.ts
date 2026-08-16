// SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
// SPDX-License-Identifier: AGPL-3.0-or-later

import { readConfig } from './config.js';
import { createServer } from './server.js';

const config = readConfig();
const server = createServer();

server.listen(config.port, config.host, () => {
  process.stdout.write(`backend-scaffold listening on ${config.host}:${String(config.port)}\n`);
});

function shutdown(): void {
  server.close((error) => {
    if (error) {
      process.stderr.write('backend-scaffold shutdown failed\n');
      process.exitCode = 1;
    }
  });
}

process.once('SIGINT', shutdown);
process.once('SIGTERM', shutdown);
