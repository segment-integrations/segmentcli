import { CommandModule } from 'yargs'
import { EdgeFunctionService } from '../../types'
import fs from 'fs'
import path from 'path'
import chalk from 'chalk'
import ora from 'ora'

export function initialize(api: EdgeFunctionService): CommandModule {
  return {
    command: 'upload',
    describe: 'Uploads the bundle, and makes it available for devices to download',
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
        .option('bundle', {
          alias: 'b',
          desc: 'edge function JS bundle',
          demandOption: true,
        })
    ),
    handler: async (argv: any) => {
      const filePath = path.resolve(argv.bundle)

      if (!fs.existsSync(filePath)) {
        console.log(`${ chalk.red('Oh no ❌! That edge function bundle does not exist.') }`)
        return
      }

      const spinner = ora('Uploading Edge Function bundle').start()
      try {
        const resp = await api.upload(argv['workspace-name'], argv['source-name'], filePath)
        spinner.succeed(` ${ chalk.green('Success') } 🎉!

Your bundle is ${ chalk.green('now usable') } on edge devices and is viewable at ${chalk.blue(resp.download_url)}.
See our ${ chalk.green('docs below') } for instructions about how to use it on edge devices:

${ chalk.yellow('https://segment.com/docs/connections/sources/catalog') }
      `)
      } catch (error) {
        spinner.fail(`${chalk.red('Oh no ❌! Looks like there was a problem uploading your edge function bundle.')}`)
        console.log(`${error}`)
        return
      }

    },
  }
}
