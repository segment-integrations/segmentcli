import { EdgeFunctionService } from '../../types'
import { CommandModule } from 'yargs'
import chalk from 'chalk'
import ora from 'ora'

export function initialize(api: EdgeFunctionService): CommandModule {
  return {
    command: 'disable',
    describe: 'Disables the edge function',
    builder: cmd => (
      cmd
        .option('workspace-name', {
          alias: 'w',
          desc: 'workspace name to which the source belongs',
          demandOption: true,
        })
        .option('source-name', {
          alias: 's',
          desc: 'source name',
          demandOption: true,
        })
    ),
    handler: async (argv: any) => {
      const spinner = ora('Disabling Edge Function').start();
      try {
        await api.disable(argv['workspace-name'], argv['source-name'])
        spinner.stop()
        spinner.succeed(` ${chalk.green('Edge Function disabled successfully')}`)
      } catch (error) {
        spinner.fail(`${ chalk.red('Oh no ❌! Looks like there was a problem disabling your latest edge function.') }`)
        console.log(`${error}`)
      }
    },
  }
}
