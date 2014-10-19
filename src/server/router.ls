{each} = require 'prelude-ls'

const routes =
  get:  []
  post: []
  put:  []

class Route
  (path, controller) ->
    @path       = path
    @controller = controller

class RoutingError extends Error
  (code, message) ->
    @code    = code
    @message = message

exports.RoutingError = RoutingError

extract-path-params = (path, matcher) ->
  # TODO this
  # Parse paths like /records/:id and shit...
  # Return undefined if the path doesn't even match the route path (matcher)
  if path.to-lower-case! == matcher.to-lower-case!
    {}
  else
    undefined

exports.route = (method, path, callback) !-->
  console.log "Routing for #method #path"
  
  const module = routes[method.to-lower-case!] |> each (route) !->
    const path-params = extract-path-params(path, route.path)
    unless path-params is undefined
      const controller-module = require("./controllers/#{route.controller}")
      return callback(controller-module, path-params)

  module or throw new RoutingError(404, "No controller for #method #path")

add-route = (method, path, options) -->
  console.log "Added route for #{method.to-upper-case!} #path : #{options.to}"
  routes[method].push new Route(path, options.to)

exports.get  = add-route 'get'
exports.post = add-route 'post'
exports.put  = add-route 'put'
