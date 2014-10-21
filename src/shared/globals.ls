@exports-for 'shared/globals' if @is-client

# To allow easy importing of prelude functions in a uniform way.
# (require is renamed to prequire for the browser so it doesn't
# conflict with the actual 'require'):
# {each map flatten} = prelude!
(@global or this).prelude = -> (prequire or require) 'prelude-ls'
