import { CommandModule } from 'yargs';
import { EdgeFunctionService } from '../../types';
import fs from 'fs';
import path from 'path';
import chalk from 'chalk';

export function initialize(api: EdgeFunctionService): CommandModule {
  return {
    command: 'upload <jsBundle>',
    describe: 'Uploads the bundle',
    builder: cmd => (
      cmd.positional('jsBundle', {
        desc: 'edge function JS bundle',
        demandOption: true,
      })
    ),
    handler: async (argv: any) => {
      const filePath = path.resolve(argv.jsBundle);

      if (!fs.existsSync(filePath)) {
        console.log('Oh no ❌! That edge function bundle does not exist.');
        return;
      }

      try {
        await api.upload(filePath);
      } catch (error) {
        console.log('Oh no ❌! Looks like there was a problem uploading your edge function bundle.');
        return;
      }

      console.log(`
${chalk.green('Success')} 🎉!

Your bundle is ${chalk.green('now usable')} on edge devices. See our ${chalk.green('docs below')} for instructions
about how to use it on edge devices:

${chalk.yellow('https://segment.com/docs/connections/sources/catalog')}
      `);
    },
  };
}