import { CommandModule } from 'yargs';

export function initialize(): CommandModule {
  return {
    command: 'init',
    describe: 'Create a new edge function middleware bundle',
    builder: {},
    handler: (argv: any) => {
      console.log('InitCommand: ', argv);
    },
  };
}