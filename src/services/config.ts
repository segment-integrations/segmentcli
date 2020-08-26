import { Config, ConfigReader } from '../types';
import fs from 'fs';
import path from 'path';
import * as os from 'os';

export const CONFIG_PATH = process.env.SEGMENT_CLI_CONFIG_PATH || path.join(os.homedir(), '.segmentcli')

export class ConfigReaderAPI implements ConfigReader {
  public async fetch(): Promise<Config> {
    const content = fs.readFileSync(CONFIG_PATH, 'utf8')
    return JSON.parse(content) as Config
  }

  public async store(cfg: Config): Promise<void> {
    fs.writeFileSync(CONFIG_PATH, JSON.stringify(cfg), 'utf8')
  }
}
