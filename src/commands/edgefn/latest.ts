import { EdgeFunction, EdgeFunctionService } from '../../types'
import { CommandModule } from 'yargs'
import chalk from 'chalk'
import ora from 'ora'

export function initialize(api: EdgeFunctionService): CommandModule {
  return {
    command: 'latest',
    describe: 'Fetches the latest edge function details',
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
      const spinner = ora('Fetching Edge Functions').start();
      try {
        const resp: EdgeFunction = await api.latest(argv['workspace-name'], argv['source-name'])
        spinner.stop()
        spinner.succeed(` ${chalk.green('Here is the latest Edge Function')}
${chalk.bold('Version             :')} ${chalk.blue(resp.version)}
${chalk.bold('Created At          :')} ${chalk.blue(resp.created_at)}
${chalk.bold('Bundle Download URL :')} ${chalk.blue(resp.download_url || '')}
${chalk.bold('Source ID           :')} ${chalk.blue(resp.source_id)}
`)
      } catch (error) {
        spinner.fail(`${ chalk.red('Oh no ❌! Looks like there was a problem fetching your latest edge function.') }`)
        console.log(`${error}`)
      }
    },
  }
}
