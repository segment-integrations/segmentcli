import * as yargs from 'yargs';
import * as EdgefnCommand from './commands/edgefn';
import { EdgeFunctionAPI } from './services/api';

const edgefnAPI = new EdgeFunctionAPI();

yargs
  .scriptName('segmentcli')
  .wrap(yargs.terminalWidth())
  .command(EdgefnCommand.initialize(edgefnAPI))
  .parse();
