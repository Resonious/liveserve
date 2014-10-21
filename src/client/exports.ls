{take-while} = prequire 'prelude-ls' # No prelude! here because that is defined after this

@is-client = true
@loaded-modules = new HashMap()

# This MUST be called in all shared scripts, with the pathname
# of the script:
# @exports-for 'shared/shared-test' if @is-client
@exports-for = (path) ->
  const e = {}
  @loaded-modules.set path, e
  @current-path = path
  # console.log "made exports for #path"
  
  this.exports = e

@require = (path) ->
  var real-path

  switch
  | (path.index-of './') is 0 =>
    const base-path = take-while (isnt '/'), @current-path
    real-path := path.replace './', base-path
  
  | (path.index-of '../') is 0 =>
    real-path := path.substr 3

  | otherwise => throw "Not sure what to do with require(#path)"  

  val = @loaded-modules.get(real-path)
  if val is undefined
    throw "TODO Couldn't find #real-path. Ajax that shit"
  else
    return val

  # console.log "requiring #key"
  # val = undefined
  # @loaded-modules.for-each (value, key) ->
  #   return val := value if (search.index-of key) > -1
  # val
