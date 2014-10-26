require! <[http url fs]>
require! './router'
require! '../shared/globals'
{any} = require('prelude-ls')

class ServerError extends Error
  (message) ->
    @code = 500
    @message = message

class Render
  content: ''
  head: false

  (arg) ->
    return if arg is undefined
    switch typeof arg
    | 'object' =>
      @content = arg.content
      @head    = arg.head
    | 'string' =>
      @content = arg

print-error = (error, response, path) !->
  if error is undefined
    console.log "UNDEFINED WAS THROWN"
    console.log (new Error).stack
    response.write-head 500
    response.end!
    return
  if error.message is undefined or error.code is undefined
    console.log "UNKNOWN ERROR #error"
    console.log error.stack
    response.write-head 500
    response.end!
    return

  console.log ''
  console.log "vvvERRORvvv"
  console.log error.message
  console.log "^^^ERROR^^^"

  response.write-head error.code, {"Content-Type": "text/plain"}
  response.write error.message

render = (controller, params) -->
  error = -> throw new ServerError("Invalid controller #controller")

  const r = switch typeof controller
  | 'function' => controller(params)
  | 'object' =>
    match typeof controller.render
    | 'string'   => controller.render
    | 'object'   => controller.render
    | 'function' => controller.render(params)
    | otherwise => error!
  | otherwise => error!

  new Render(r)

handle-by-controller = (method, path, response) ->
  controller, path-params <- router.route(method, path)
  path-params.path = path
  const rendered = render controller, path-params

  response.write-head 200, (rendered.head or {"Content-Type": "text/html"})
  response.write(rendered.content)

  # TODO http params as well as path-params (which don't even exist anyway!)

mime-type-from = (path) ->
  const extension = path.substr path.last-index-of('.')
  switch extension
  | '.js'   => 'text/javascript'
  | '.png'  => 'image/png'
  | '.html' => 'text/html'

handle-static-file = (path, response) ->
  console.log "Serving up static file at #path"
  response.write-head 200, {"Content-Type": mime-type-from path}
  response.write fs.read-file-sync(path, 'utf8')

# NOTE: This assumes the server is being run from the project root.
public-file = (path) -> "site/public#path"
client-file = (path) -> "site/client#path"

is-valid-file = (path, type) -->
  console.log "type: #type"
  console.log "path: #path"
  switch
  | (path.index-of '/#type/') is 0 and fs.exists-sync "site#path" =>
    "site#path"
  | otherwise => undefined

is-valid-static = (path) ->
  <[client shared]> |> any (type) ->
    (path.index-of "/#type/") is 0 and fs.exists-sync "site#path"

var server

exports.start = !->
  const port = 8080

  console.log 'Server started!'
  require('./routes')

  server := http.create-server (request, response) ->
    const path = (url.parse request.url).pathname
    const method = request.method

    try
      switch
      | router.route-exists-for method, path =>
        handle-by-controller method, path, response
      
      | method is 'GET' =>
        switch
        | fs.exists-sync public-file path =>
          handle-static-file (public-file path), response
        
        | is-valid-static path
          handle-static-file "site#path", response

        | otherwise =>
          throw new router.RoutingError("No file or controller for #path")

      | otherwise =>
        throw new router.RoutingError("No file or controller for #path")

    catch error
      print-error(error, response, path)

    console.log '-------------------------------------------------------------'
    response.end!

  server.listen port
  process.on 'exit' server~close
  server.on 'close' ->
    try
      process.exit 0
    catch error

  console.log "Up and running on port #{port}!"

process.on 'message' (message) ->
    switch message.type
    | \start =>
      exports.start!

    | \unrequire =>
      console.log 'Clearing require cache'
      for key in Object.keys(require.cache)
        delete require.cache[key]
    
    | \close =>
      console.log 'bye'
      try
        server.close!
      catch e
        process.kill!
    
    | otherwise =>
      console.log "got message #message ???"
