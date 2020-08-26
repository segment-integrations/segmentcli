import fs from 'fs'
import path from 'path'
import vm from 'vm'
import { CommandModule } from 'yargs'
import chalk from 'chalk'

interface TestJSON {
  input?: any
  output?: any
}

export function initialize(): CommandModule {
  return {
    command: 'test <jsBundle>',
    describe: 'Test an edge function bundle',
    builder: cmd => (
      cmd
        .positional('jsBundle', {
          describe: 'The JavaScript bundle to test',
        })
        .option('input', {
          type: 'string',
          desc: 'Location of JSON file to feed through the bundle',
          demandOption: true,
        })
        .option('verbose', {
          type: 'boolean',
          desc: 'Enables more verbose output',
          default: false,
        })
    ),
    handler: (argv: any) => {
      let testFile: TestJSON = {}

      if (!fs.existsSync(argv.jsBundle)) {
        console.log(`Oh no ❌! File containing an ${ chalk.red('edge function bundle') } does not exist!`)
        return
      }

      if (argv.input) {
        if (!fs.existsSync(argv.input)) {
          console.log(`Oh no ❌! The ${ chalk.red('input JSON file') } does not exist!`)
          return
        }

        testFile = require(path.resolve(argv.input))

        if (!testFile.input || testFile.output === undefined) {
          console.log(`
Input JSON ${ chalk.red('not') } in the ${ chalk.red('correct format') }!

File needs to be in the format:
{
  "input": {},
  "output": {}
}
          `)
          return
        }
      }

      const jsBundle = fs.readFileSync(path.resolve(argv.jsBundle), 'utf8')
      const script = new vm.Script(jsBundle, { filename: 'jsBundle', timeout: 5000 })
      const context: any = {}

      try {
        script.runInNewContext(context)
      } catch (error) {
        console.log(`Oh no ❌! Looks like there was an ${ chalk.red('error in your edge function bundle') }:\n`)
        console.log(error)
        return
      }

      if (typeof context.middleware !== 'object') {
        console.log(`Oh no ❌! Your edge function bundle doesn't ${ chalk.red('export an middlewares') } functions.
${ chalk.yellow('Ensure that you configured the webpack properly') }`)
        return
      }
      if (!Array.isArray(context.middleware.sourceMiddleware)) {
        console.log(`Oh no ❌! Your edge function bundle doesn't ${ chalk.red('export an array of sourceMiddleware') } functions.`)
        return
      }
      if (!context.middleware.destinationMiddleware) {
        console.log(`Oh no ❌! Your edge function bundle doesn't ${ chalk.red('export a dictionary of destinationMiddleware') } functions.`)
        return
      }

      if (argv.input) {
        let result = Object.assign({}, testFile.input)

        if (argv.verbose) {
          console.log(`Input: ${ JSON.stringify(result, null, 2) }`)
        }

        // Run All sourceMiddleware functions
        for (const func of context.middleware.sourceMiddleware) {
          result = func(result)

          if (argv.verbose) {
            console.log(`\n${ chalk.bold(`Output from sourceMiddleware.${ func.name }:`) } ${ JSON.stringify(result, null, 2) }`)
          }
        }

        const testResult: any = {}

        // Run All destinationMiddleware functions
        for (const destination of Object.keys(context.middleware.destinationMiddleware)) {
          let destinationResult = Object.assign({}, result)
          const funcList = context.middleware.destinationMiddleware[destination]

          // Run singular destination's middleware
          for (const func of funcList) {
            destinationResult = func(destinationResult)

            if (argv.verbose) {
              console.log(`\n${ chalk.bold(`Output from destinationMiddleware [${ destination }].${ func.name }`) } : ${ JSON.stringify(destinationResult, null, 2) }`)
            }
          }
          testResult[destination] = destinationResult
        }

        // Check if Segment.io was populated in middleware chain, if not use output of sourceMiddleware here and add as default
        if (!('Segment.io' in testResult)) {
          testResult['Segment.io'] = result
        }

        // Validate
        if (JSON.stringify(testResult) !== JSON.stringify(testFile.output)) { // todo switch this out for a better comparison
          console.log(`
Invalid output! ❌

Expected output to be:
${ chalk.green(JSON.stringify(testFile.output, null, 2)) }

But received:
${ chalk.red(JSON.stringify(testResult, null, 2)) }
          `)

          return
        }
      } else {
        console.log(`Only checking file structure. Use ${ chalk.magenta('--input') } to provide a test file.`)
      }

      console.log(`
${ chalk.green('Passed! 🎉') }

Use the below command to upload this bundle to the web:

${ chalk.magenta(`segmentcli edgefn upload ${ argv.jsBundle }`) }
      `)
    },
  }
}
