import * as yargs from 'yargs';
import * as EdgefnCommand from './commands/edgefn';
import { EdgeFunctionAPI } from './services/api';

yargs
  .command(EdgefnCommand.initialize(new EdgeFunctionAPI()))
  .argv
