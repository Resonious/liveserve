{each, map, join} = require 'prelude-ls'

gather-scripts = (scripts) ->
  return '' if scripts is undefined
  
  join "\n" (scripts |> map -> "<script src='#it'></script>")

exports.standard = (content, options) ->
  options = {} if options is undefined
  # TODO
  # Add a <script> tag for some kind of 'require' replacement for 
  # in-browser javascript.....
  """
  <!DOCTYPE html>
  <html>

    <head>
      <meta charset="UTF-8" />
      <script src="prelude.min.js"></script>
      <script src="hashmap.js"></script>
      <script src="exports.js"></script>
      <script src="shared/globals.js"></script>
      #{gather-scripts options.scripts}
      <title>#{options.title or 'Crattle Crute!'}</title>
    </head>

    <body>
      #content
    </body>

  </html>
  """
