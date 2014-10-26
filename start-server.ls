{fork} = require('child_process')

const start-server = '''"require('./site/server/server').start();"'''

console.log 'Attempting to run server...'

server = fork './server.js', [],
  cwd: 'site/server'

server.on \close, (code) ->
  console.log "Server closed with code #code"

server.on \error, (err) ->
  console.log "ERROR #err"

console.log process.exec-path
