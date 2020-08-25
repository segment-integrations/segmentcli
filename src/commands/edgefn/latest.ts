import { EdgeFunctionService } from '../../types';
import { CommandModule } from 'yargs';
import chalk from 'chalk';

export function initialize(api: EdgeFunctionService): CommandModule {
  return {
    command: 'latest <workspace_name> <source_name>',
    describe: 'Fetches the latest edge function details',
    builder: cmd => (
      cmd
        .positional('workspace_name', {
          desc: 'workspace name to which the source belongs',
          demandOption: true,
        })
        .positional('source_name', {
          desc: 'source name',
          demandOption: true,
        })
    ),
    handler: async (argv: any) => {
      try {
        const resp = await api.latest(argv.workspace_name, argv.source_name)
        console.log(`${ chalk.green(JSON.stringify(resp, null, 4)) }`)
      } catch (error) {
        console.log(`${ chalk.red('Oh no ❌! Looks like there was a problem fetching your latest edge function.') }`)
        return
      }
    },
  }
}
