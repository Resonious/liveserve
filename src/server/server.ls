require! <[http url fs]>
require! './router'

class ServerError extends Error
  (message) ->
    @code = 500
    @message = message

render = (controller, params) -->
  match typeof controller.render
  | (is 'string')   => controller.render
  | (is 'function') => controller.render!
  | otherwise => throw new ServerError("Invalid controller #controller")

exports.start = !->
  const port = 8080

  require('./routes')

  http.create-server (request, response) ->
    const path = (url.parse request.url).pathname
    const method = request.method

    try
      controller, path-params <- router.route(method, path)
      response.write-head 200, {"Content-Type": "text/html"}
      response.write(render controller, path-params)
      # TODO http params as well as path-params (which don't even exist anyway!)

    catch error
      if error.message is undefined or error.code is undefined
        console.log "UNKNOWN ERROR #error"
        console.log error.stack
        response.end!
        return

      console.log ''
      console.log "vvvERRORvvv"
      console.log error.message
      console.log "^^^ERROR^^^"

      response.write-head error.code, {"Content-Type": "text/plain"}
      response.write error.message

    response.end!

  .listen port

  console.log "Up and running on port #{port}!"
