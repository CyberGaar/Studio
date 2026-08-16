// SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
// SPDX-License-Identifier: AGPL-3.0-or-later

export interface ServiceConfig {
  readonly host: string;
  readonly nodeEnv: 'development' | 'production' | 'test';
  readonly port: number;
}

const environments = new Set<ServiceConfig['nodeEnv']>([
  'development',
  'production',
  'test',
]);

export function readConfig(environment: NodeJS.ProcessEnv = process.env): ServiceConfig {
  const host = environment.HOST?.trim() || '127.0.0.1';
  const nodeEnv = environment.NODE_ENV?.trim() || 'development';
  const portText = environment.PORT?.trim() || '3001';
  const port = Number(portText);

  if (!environments.has(nodeEnv as ServiceConfig['nodeEnv'])) {
    throw new Error('NODE_ENV must be development, production, or test.');
  }
  if (!Number.isInteger(port) || port < 1 || port > 65_535) {
    throw new Error('PORT must be an integer between 1 and 65535.');
  }

  return { host, nodeEnv: nodeEnv as ServiceConfig['nodeEnv'], port };
}
