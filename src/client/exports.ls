{split, join} = prequire 'prelude-ls' # No prelude! here because that is defined after this

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
    # TODO This has not been tested
    const base-dirs = split '/' @current-path
    const path-dirs = split '/' path

    const target = for i in [0 til path-dirs.length]
      switch path-dirs[i]
      | '../'     => base-dirs[i]
      | otherwise => path-dirs[i]

    real-path := join '/' target

  | otherwise => throw "Not sure what to do with require(#path)"  

  val = @loaded-modules.get(real-path)
  if val is undefined
    throw "TODO Couldn't find #real-path. Ajax that shit"
  else
    return val
