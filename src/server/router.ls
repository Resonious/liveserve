{each, any} = require 'prelude-ls'

const routes =
  get:  []
  post: []
  put:  []

class Route
  (path, controller) ->
    @path       = path
    @controller = controller

class RoutingError extends Error
  (message) ->
    @code    = 404
    @message = message

exports.RoutingError = RoutingError

test-path = (path, route) -->
  # TODO
  # Parse paths like /records/:id and shit...
  # Return undefined if the path doesn't even match the route path (matcher)
  path.to-lower-case! == route.path.to-lower-case!

extract-path-params = (path, route) ->
  # TODO this
  if test-path path, route
    {}
  else
    undefined

exports.route-exists-for = (method, path) -->
  any test-path(path), routes[method.to-lower-case!]

exports.route = (method, path, callback) !-->
  console.log "Routing for #method #path"

  const module = routes[method.to-lower-case!] |> each (route) !->
    const path-params = extract-path-params(path, route)
    unless path-params is undefined
      const controller = switch typeof route.controller
      | 'string'   => require("./controllers/#{route.controller}")
      | 'function' => route.controller
      | otherwise => throw new RoutingError("Bad routed controller #{route.controller}")

      return callback(controller, path-params)

  module or throw new RoutingError("No controller for #method #path")

add-route = (method, path, options) -->
  switch typeof options.to
  | 'function' =>
    console.log "Added route for #{method.to-upper-case!} #path : <function>"
  | 'string' =>
    console.log "Added route for #{method.to-upper-case!} #path : #{options.to}"
  
  routes[method].push new Route(path, options.to)

exports.get  = add-route 'get'
exports.post = add-route 'post'
exports.put  = add-route 'put'
