{exec, fork, spawn} = require('child_process')
{last, each, split} = require('prelude-ls')
require! 'fs'

last-source = ''

print-from = (source, content) !-->
  if source isnt last-source
    last-source := source
    console.log "============================ #source ============================"
  process.stdout.write content

# ======================== Server process ======================

const start-server-cmd = '''
  "require('./site/server/server').start();"
'''
const server-path = "./site/server/server.js"
var server

function start-server
  server := fork server-path, [], silent: true

  server.stdout.on 'data' print-from('SERVER')
  server.stderr.on 'data' print-from('SERVER')

  server.send type: \start
    
  server.on 'close' (code) ->
    unless handling-changes
      console.log "Server closed with code #code. Restarting in 5 seconds..."
      set-timeout start-server, 5000


# ======================== Build Watch =======================

function start-build-process
  console.log 'Starting build watch process...'

  exec 'lsc -wco site src'
    ..stdout.on 'data' print-from('BUILD')
    ..stderr.on 'data' print-from('BUILD')

    ..on 'close' (code) ->
      console.log "Build process closed with code #code"
      start-build-process!

    ..stdout.on 'data' (content) ->
      on-file-changed content if server and /Failed at/ != content

# ======================== File watch ========================

handling-changes = false

function on-file-changed filename
  const print = print-from 'FILE WATCH'

  return if handling-changes
  handling-changes := true

  if /server\.[jl]s/ == filename
    print "Restarting server!\n"
    # server.send type: \close
    server.kill!
    set-timeout (-> start-server!; handling-changes := false), 100
  else
    server.send type: \unrequire
    set-timeout (-> handling-changes := false), 10

# =========================
start-build-process!
set-timeout start-server, 500
