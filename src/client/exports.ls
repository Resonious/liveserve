{split, join, at, initial, reject, take} = prequire 'prelude-ls' # No prelude! here because that is defined after this

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
    const base-path = @current-path.substring 0, @current-path.last-index-of '/'
    real-path := path.replace './', base-path
  
  | (path.index-of '../') is 0 =>
    # NOTE
    # This will only account for leading "../"s, meaning 
    # it doesn't work with "/test/../duhh/imdumb" because
    # that is an absurd thing to say. (Although that might
    # show up dynamically)
    const base-dirs = initial split '/' @current-path
    const path-dirs = split '/' path

    const non-back-path-dirs = reject (is '..'), path-dirs
    back-count = path-dirs.length - non-back-path-dirs.length

    const target-base-dirs = take base-dirs.length - back-count, base-dirs

    const target = target-base-dirs ++ non-back-path-dirs

    real-path := join '/' target
    real-path

  | otherwise => throw "Not sure what to do with require(#path)"  

  val = @loaded-modules.get(real-path)
  if val is undefined
    throw "TODO Couldn't find #real-path. Ajax that shit"
  else
    return val
