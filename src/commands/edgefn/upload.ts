import { CommandModule } from 'yargs';
import { EdgeFunctionService } from '../../types';
import fs from 'fs';
import path from 'path';

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
        console.log('That edge function bundle does not exist!');
        return;
      }

      await api.upload(filePath);
    },
  };
}