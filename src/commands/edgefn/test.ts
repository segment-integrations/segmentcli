import fs from 'fs';
import path from 'path';
import vm from 'vm';
import { CommandModule } from 'yargs';
import chalk from 'chalk';

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
          desc: 'Location of an input JSON file to feed through the bundle',
          implies: 'output',
        })
        .option('output', {
          type: 'string',
          desc: 'The expected output JSON given the included input',
          implies: 'input',
        })
        .option('verbose', {
          type: 'boolean',
          desc: 'Enables more verbose output',
          default: false,
        })
    ),
    handler: (argv: any) => {
      let input = {};
      let output = {};

      if (!fs.existsSync(argv.jsBundle)) {
        console.log(`The ${chalk.red('edge function bundle')} does not exist!`);
        return;
      }

      if (argv.input || argv.output) {
        let valid = true;
        if (!fs.existsSync(argv.input)) {
          console.log(`The ${chalk.red('input JSON file')} does not exist!`);
          valid = false;
        } else {
          input = require(path.resolve(argv.input));
        }

        if (!fs.existsSync(argv.output)) {
          console.log(`The ${chalk.red('output JSON file')} does not exist!`);
          valid = false;
        } else {
          output = require(path.resolve(argv.output));
        }

        if (!valid) return;
      }

      const jsBundle = fs.readFileSync(path.resolve(argv.jsBundle), 'utf8');
      const script = new vm.Script(jsBundle, { filename: 'jsBundle', timeout: 5000 });
      const context: any = {};

      try {
        script.runInNewContext(context);
      } catch (error) {
        console.log(`Looks like there was an ${chalk.red('error in your edge function bundle')}:\n`)
        console.log(error);
        return;
      }

      if (!Array.isArray(context.middleware)) {
        console.log(`Your edge function bundle doesn\'t ${chalk.red('export an array of middleware')} functions.`);
        return;
      }

      if (argv.input || argv.output) {
        let result = input;

        if (argv.verbose) {
          console.log(`Input: ${JSON.stringify(result, null, 2)}`);
        }

        for (const func of context.middleware) {
          result = func(result);

          if (argv.verbose) {
            console.log(`\nOutput from ${func.name}: ${JSON.stringify(result, null, 2)}`);
          }
        }

        if (JSON.stringify(result) !== JSON.stringify(output)) {
          console.log(`
Invalid output! ❌

Expected output to be:
${chalk.green(JSON.stringify(output, null, 2))}

But received:
${chalk.red(JSON.stringify(result, null, 2))}
          `);

          return;
        }
      } else {
        console.log('Only checking file structure...');
      }

      console.log(`
${chalk.green('Passed! 🎉')}

Use the below command to upload this bundle to the web:

${chalk.magenta('segmentcli edgefn upload <jsBundle>')}
      `);
    },
  };
}