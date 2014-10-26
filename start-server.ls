{fork} = require('child_process')
spawn = require('win-spawn')
{last, each, split} = require('prelude-ls')
require! 'fs'
require! 'rimraf'

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

var build
restarting-build = false

function start-build-process
  console.log 'Starting build watch process...'

  # build := exec 'lsc -wco site src'
  build := spawn 'lsc', <[-wco site src]>
    ..stdout.on 'data' print-from('BUILD')
    ..stderr.on 'data' print-from('BUILD')

    ..on 'close' (code) ->
      if restarting-build
        console.log 'Restarting build process...'
        restarting-build := false
      else
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

# =========================== Input ===============================

let print = (-> print-from 'COMMAND', "#it\n")
  process.stdin
    ..set-encoding 'utf8'
    ..on 'readable' ->
      const input = process.stdin.read!
      return unless input
      
      switch input.trim!
      | '' =>

      | \clean =>
        count = 0
        <[./site/client ./site/shared ./site/server]> |> each (path) ->
          rimraf path, (err) ->
            print err if err
            count := count + 1
            if count >= 3
              count := 0
              console.log "Cleared compiled files. I recommend you restart this thing."
              # restarting-build := true
              # console.log build.killed
              # process.kill build.pid, \SIGINT
              # console.log build.killed

      | otherwise =>
        print "Don't know what you mean by #that" unless that is null
