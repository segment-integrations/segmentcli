#!/usr/bin/env node

import * as yargs from 'yargs'
import * as EdgefnCommand from './commands/edgefn'
import * as AuthCommand from './commands/auth'
import { EdgeFunctionAPI } from './services/api'
import { ConfigReaderAPI } from './services/config'

const configReader = new ConfigReaderAPI()
const edgefnAPI = new EdgeFunctionAPI(configReader)

yargs
  .scriptName('segmentcli')
  .wrap(yargs.terminalWidth())
  .command(AuthCommand.initialize(configReader))
  .command(EdgefnCommand.initialize(edgefnAPI))
  .demandCommand(1, 'Command required')
  .parse()
