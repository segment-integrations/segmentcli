import { CommandModule } from 'yargs'
import { EdgeFunctionService } from '../../types'
import fs from 'fs'
import path from 'path'
import chalk from 'chalk'

export function initialize(api: EdgeFunctionService): CommandModule {
  return {
    command: 'upload <workspace_name> <source_name> <jsBundle>',
    describe: 'Uploads the bundle',
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
        .positional('jsBundle', {
          desc: 'edge function JS bundle',
          demandOption: true,
        })
    ),
    handler: async (argv: any) => {
      const filePath = path.resolve(argv.jsBundle)

      if (!fs.existsSync(filePath)) {
        console.log(`${ chalk.red('Oh no ❌! That edge function bundle does not exist.') }`)
        return
      }

      try {
        const resp = await api.upload(argv.workspace_name, argv.source_name, filePath)
        console.log(`
${ chalk.green('Success') } 🎉!

Your bundle is ${ chalk.green('now usable') } on edge devices and is viewable at ${chalk.blue(resp.download_url)}. See our ${ chalk.green('docs below') } for instructions
about how to use it on edge devices:

${ chalk.yellow('https://segment.com/docs/connections/sources/catalog') }
      `)
      } catch (error) {
        console.log(`${chalk.red('Oh no ❌! Looks like there was a problem uploading your edge function bundle.')}`)
        return
      }

    },
  }
}
