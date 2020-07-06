import * as yargs from 'yargs';
import * as EdgefnCommand from './commands/edgefn';
import { EdgeFunctionAPI } from './services/api';

const edgefnAPI = new EdgeFunctionAPI();

yargs
  .command(EdgefnCommand.initialize(edgefnAPI))
  .parse();
