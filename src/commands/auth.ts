import { CommandModule } from 'yargs'
import { Config, ConfigReader } from '../types';

export function initialize(configReader: ConfigReader): CommandModule {
  return {
    command: 'auth <token>',
    describe: 'stores the access token',
    builder: cmd => (
      cmd.positional('token', {
        desc: 'access-token retrieved from app.segment.com',
        demandOption: true,
      })
    ),
    handler: async (argv: any) => {
      const token = argv.token
      let cfg: Config
      try {
        cfg = await configReader.fetch()
      } catch (_) {
        cfg = { token: '' }
      }
      cfg.token = token
      await configReader.store(cfg)
    },
  };
}
