import { CommandModule } from 'yargs';
import fsExtra from 'fs-extra';
import path from 'path';
import process from 'process';
import chalk from 'chalk';

const basePackageJSON = {
  name: 'edgefn-sample',
  version: '1.0.0',
  description: '',
  scripts: {
    build: 'webpack',
    pretest: 'npm run build',
    test: 'segmentcli edgefn test dist/index.js',
  },
  keywords: [],
  author: '',
  license: 'ISC',
  devDependencies: {
    'clean-webpack-plugin': '^3.0.0',
    'ts-loader': '^7.0.5',
    'ts-node': '^8.3.0',
    tslint: '^5.18.0',
    'tslint-config-airbnb': '^5.11.1',
    typescript: '^3.5.3',
    webpack: '^4.43.0',
    'webpack-cli': '^3.3.12',
    '@types/lodash': '^4.14.157',
  },
  dependencies: {
    lodash: '^4.17.15',
  },
};

const baseTSConfig = {
  compilerOptions: {
    target: 'ES6',
    module: 'commonjs',
    sourceMap: false,
    outDir: './dist',
    rootDir: './src',
    lib: ['ES6'],

    strict: true,
    noImplicitAny: true,
    strictNullChecks: true,
    strictFunctionTypes: true,
    strictBindCallApply: true,
    strictPropertyInitialization: true,
    noImplicitThis: true,
    alwaysStrict: true,

    noUnusedLocals: true,
    noImplicitReturns: true,

    moduleResolution: 'node',
    rootDirs: ['src'],
    typeRoots: ['node_modules/@types/'],
    allowSyntheticDefaultImports: true,
    resolveJsonModule: true,
    esModuleInterop: true,
  },
};

export function initialize(): CommandModule {
  return {
    command: 'init <bundleName>',
    describe: 'Create a new edge function middleware bundle',
    builder: cmd => (
      cmd
        .positional('bundleName', {
          desc: 'name to use for the new edge function bundle',
          demandOption: true,
        })
    ),
    handler: async (argv: any) => {
      const templateDir = path.resolve(__dirname, '../../templates/edgefn');
      const newDir  = path.resolve(process.cwd(), argv.bundleName);

      await fsExtra.copy(templateDir, newDir);
      await fsExtra.outputJSON(path.resolve(newDir, 'package.json'), basePackageJSON);
      await fsExtra.outputJSON(path.resolve(newDir, 'tsconfig.json'), baseTSConfig);

      console.log(`
Your new ${chalk.green('edge function')} project is ${chalk.green('ready for editing')}! 🎉

Open ${chalk.yellow(`${argv.bundleName}/README.md`)} in your favourite editor to learn more.

Or, run the below command to compile the sample version:

${chalk.magenta(`cd ${argv.bundleName} && yarn install && yarn build`)}
      `);
    },
  };
}