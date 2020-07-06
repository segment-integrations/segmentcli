import { CommandModule } from 'yargs';
import * as InitCommand from './init';
import * as UploadCommand from './upload';
import { EdgeFunctionService } from '../../types';

export function initialize(api: EdgeFunctionService): CommandModule {
  return {
    command: 'edgefn',
    describe: 'Contains all the edge function commands',
    builder: yargs => (
      yargs
        .command(InitCommand.initialize())
        .command(UploadCommand.initialize(api))
    ),
    handler: (argv: any) => {
      console.log('edgefn: ', argv);
    },
  };
}