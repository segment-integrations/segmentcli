import { CommandModule } from 'yargs';
import { EdgeFunctionService } from '../../types';

export function initialize(api: EdgeFunctionService): CommandModule {
  return {
    command: 'upload <bundleDir>',
    describe: 'Uploads the bundle',
    builder: {},
    handler: (argv: any) => {
      api.upload();
    },
  };
}