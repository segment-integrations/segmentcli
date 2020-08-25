import { CommandModule } from 'yargs'
import { Config, ConfigReader } from '../types'
import chalk from 'chalk'
import { CONFIG_PATH } from '../services/config';

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
      try {
        await configReader.store(cfg)
        console.log(`${chalk.green('Success') } 🎉! authentication credentials persisted and can be found at ${chalk.blue(CONFIG_PATH)}`)
      } catch (error) {
        console.log(`${chalk.red} Error storing auth token`)
      }
    },
  };
}
