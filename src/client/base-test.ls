@exports-for 'client/base-test' if @is-client
require! '../shared/shared-test'

console.log "FROM BASE: #{shared-test.test-val}"
