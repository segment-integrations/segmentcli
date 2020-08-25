import { CommandModule } from 'yargs';
import * as InitCommand from './init';
import * as UploadCommand from './upload';
import * as GetLatestCommand from './latest';
import * as TestCommand from './test';
import { EdgeFunctionService } from '../../types';
import chalk from 'chalk';

export function initialize(api: EdgeFunctionService): CommandModule {
  return {
    command: 'edgefn <command>',
    describe: chalk.green('contains all the edge function commands'),
    builder: yargs => (
      yargs
        .command(InitCommand.initialize())
        .command(TestCommand.initialize())
        .command(GetLatestCommand.initialize(api))
        .command(UploadCommand.initialize(api))
        .demandCommand(1, 'Command required')
    ),
    handler: (_: any) => {
      console.log('unrecognized command');
    },
  };
}
