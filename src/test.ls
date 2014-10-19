const str = "some/:kind/of/:path"

r = (str, regex) ->
  while (result = regex.exec(str)) isnt null
    result

str `r` /\:\w+/g

typeof /hey/
