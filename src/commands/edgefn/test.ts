import fs from 'fs';
import path from 'path';
import vm from 'vm';
import { CommandModule } from 'yargs';
import chalk from 'chalk';

interface TestJSON {
  input?: any;
  output?: any;
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
        })
        .option('verbose', {
          type: 'boolean',
          desc: 'Enables more verbose output',
          default: false,
        })
    ),
    handler: (argv: any) => {
      let testFile: TestJSON = {};

      if (!fs.existsSync(argv.jsBundle)) {
        console.log(`Oh no ❌! File containing an ${chalk.red('edge function bundle')} does not exist!`);
        return;
      }

      if (argv.input) {
        if (!fs.existsSync(argv.input)) {
          console.log(`Oh no ❌! The ${chalk.red('input JSON file')} does not exist!`);
          return;
        }

        testFile = require(path.resolve(argv.input));

        if (!testFile.input || testFile.output === undefined) {
          console.log(`
Input JSON ${chalk.red('not')} in the ${chalk.red('correct format')}!

File needs to be in the format:
{
  "input": {},
  "output": {}
}
          `);
          return;
        }
      }

      const jsBundle = fs.readFileSync(path.resolve(argv.jsBundle), 'utf8');
      const script = new vm.Script(jsBundle, { filename: 'jsBundle', timeout: 5000 });
      const context: any = {};

      try {
        script.runInNewContext(context);
      } catch (error) {
        console.log(`Oh no ❌! Looks like there was an ${chalk.red('error in your edge function bundle')}:\n`)
        console.log(error);
        return;
      }

      if (!Array.isArray(context.middleware)) {
        console.log(`Oh no ❌! Your edge function bundle doesn\'t ${chalk.red('export an array of middleware')} functions.`);
        return;
      }

      if (argv.input || argv.output) {
        let result = Object.assign({}, testFile.input);

        if (argv.verbose) {
          console.log(`Input: ${JSON.stringify(result, null, 2)}`);
        }

        for (const func of context.middleware) {
          result = func(result);

          if (argv.verbose) {
            console.log(`\nOutput from ${func.name}: ${JSON.stringify(result, null, 2)}`);
          }
        }

        if (JSON.stringify(result) !== JSON.stringify(testFile.output)) {
          console.log(`
Invalid output! ❌

Expected output to be:
${chalk.green(JSON.stringify(testFile.output, null, 2))}

But received:
${chalk.red(JSON.stringify(result, null, 2))}
          `);

          return;
        }
      } else {
        console.log(`Only checking file structure. Use ${chalk.magenta('--input')} to provide a test file.`);
      }

      console.log(`
${chalk.green('Passed! 🎉')}

Use the below command to upload this bundle to the web:

${chalk.magenta('segmentcli edgefn upload <jsBundle>')}
      `);
    },
  };
}