import { CommandModule } from 'yargs';
import * as InitCommand from './init';
import * as UploadCommand from './upload';
import * as TestCommand from './test';
import { EdgeFunctionService } from '../../types';
import chalk from 'chalk';

export function initialize(api: EdgeFunctionService): CommandModule {
  return {
    command: 'edgefn',
    describe: chalk.green('contains all the edge function commands'),
    builder: yargs => (
      yargs
        .command(InitCommand.initialize())
        .command(TestCommand.initialize())
        .command(UploadCommand.initialize(api))
        .demandCommand(1, 'Command required')
    ),
    handler: (argv: any) => {
      console.log('edgefn: ', argv);
    },
  };
}